#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/CodeIntelligenceTesting/cifuzz"
TOOL_NAME="cifuzz"
TOOL_TEST="cifuzz --help"
INSTALLER_NAME="cifuzz_installer"

fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//'
}

list_all_versions() {
  list_github_tags
}

get_arch() {
  local arch=""
  case "$(uname -m)" in
  aarch64 | arm64) arch="arm64" ;;
  x86_64) arch="amd64" ;;
  *)
    fail "Architecture '$(uname -m)' not supported!"
    ;;
  esac
  echo -n $arch
}

get_platform() {
  local platform=""
  case "$(uname | tr '[:upper:]' '[:lower:]')" in
  darwin) platform="darwin" ;;
  linux) platform="linux" ;;
  windows) platform="windows" ;;
  *)
    fail "Platform '$(uname -m)' not supported!"
    ;;
  esac
  echo -n $platform
}

# https://stackoverflow.com/questions/4023830/how-to-compare-two-strings-in-dot-separated-version-format-in-bash
# '=' -> 0
# '>' -> 1
# '<' -> 2
vercomp() {
  if [[ $1 == $2 ]]; then
    return 0
  fi
  local IFS=.
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i = 0; i < ${#ver1[@]}; i++)); do
    if [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}

release_artifact_name() {
  local platform=$1
  local arch=$2
  local version=$3
  local ext=""

  vercomp "$version" "0.17.0"
  if [[ $? = 2 ]]; then
    # Version below 0.17.0, hence, use the old naming schema
    # Remove architecture, except on darwin
    if [[ $platform != "darwin" ]]; then
      arch=""
    fi
  else
    # Version >= 0.17.0, hence, use the new naming schema
    # Change darwin to macOS
    if [[ $platform = "darwin" ]]; then
      platform="macOS"
    fi
  fi

  if [[ $arch != "" ]]; then
    arch="_${arch}"
  fi
  if [ $platform == "windows" ]; then
    ext=".exe"
  fi

  echo -n "cifuzz_installer_${platform}${arch}${ext}"
}

download_artifact_name() {
  local platform=$(get_platform)
  local arch=$(get_arch)
  echo -n "$(release_artifact_name $platform $arch $ASDF_INSTALL_VERSION)"
}

download_release() {
  local version="$1"
  local download_path="$2"
  local filename="$(download_artifact_name)"
  local url="$GH_REPO/releases/download/v${version}/${filename}"
  echo "* Downloading $TOOL_NAME release $version..."
  curl "${curl_opts[@]}" -o "${download_path}/${INSTALLER_NAME}" -C - "$url" || fail "Could not download ${url}"
  chmod +x "${download_path}/${INSTALLER_NAME}"
}

install_version() {
  local install_type="$1"
  local version="$2"
  local install_path="$3"

  if [ "$install_type" != "version" ]; then
    fail "asdf-$TOOL_NAME supports release installs only"
  fi

  (
    mkdir -p "$install_path"
    export "CIFUZZ_INSTALLER_NO_CMAKE=1"
    ("${ASDF_DOWNLOAD_PATH}/${INSTALLER_NAME}" "--install-dir" "${install_path}" "--ignore-installation-check" "--verbose") >/dev/null 2>&1

    local tool_cmd
    tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
    test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

    # Remove symlink created by the installer script
    rm "${HOME}/.local/bin/cifuzz"

    echo "$TOOL_NAME $version installation was successful!"
  ) || (
    rm -rf "$install_path"
    fail "An error occurred while installing $TOOL_NAME $version."
  )
}
