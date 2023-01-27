#!/usr/bin/env bash

set -euo pipefail

source ../lib/utils.bash

test_release_artifact_name() {
  name=$(release_artifact_name $1 $2 $3)
  if [[ $name != "$4" ]]; then
    printf "FAIL: Expected '$4'\n        Result '$name', Platform '$1', Arch '$2', Version '$3'\n"
  else
    echo "PASS: Platform '$1 $2 $3 -> $name'"
  fi
}

# Run tests
# argument table format:
# testarg1   testarg2     expected_relationship
echo "The following tests should pass"
while read -r test; do
  test_release_artifact_name $test
done <<EOF
linux           amd64           0.16.0     cifuzz_installer_linux
linux           arm64           0.16.0     cifuzz_installer_linux
windows         amd64           0.16.0     cifuzz_installer_windows.exe
windows         arm64           0.16.0     cifuzz_installer_windows.exe
darwin          amd64           0.16.0     cifuzz_installer_darwin_amd64
darwin          arm64           0.16.0     cifuzz_installer_darwin_arm64
linux           amd64           0.17.0     cifuzz_installer_linux_amd64
linux           arm64           0.17.0     cifuzz_installer_linux_arm64
windows         amd64           0.17.0     cifuzz_installer_windows_amd64.exe
windows         arm64           0.17.0     cifuzz_installer_windows_arm64.exe
darwin          amd64           0.17.0     cifuzz_installer_macOS_amd64
darwin          arm64           0.17.0     cifuzz_installer_macOS_arm64
EOF
