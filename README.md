<div align="center">

# asdf-cifuzz [![Build](https://github.com/bertschneider/asdf-cifuzz/actions/workflows/build.yml/badge.svg)](https://github.com/bertschneider/asdf-cifuzz/actions/workflows/build.yml) [![Lint](https://github.com/bertschneider/asdf-cifuzz/actions/workflows/lint.yml/badge.svg)](https://github.com/bertschneider/asdf-cifuzz/actions/workflows/lint.yml)


[cifuzz](https://github.com/CodeIntelligenceTesting/cifuzz) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Install

Plugin:

```shell
asdf plugin add cifuzz
# or
asdf plugin add cifuzz https://github.com/bertschneider/asdf-cifuzz.git
```

cifuzz:

```shell
# Show all installable versions
asdf list-all cifuzz

# Install specific version
asdf install cifuzz latest

# Set a version globally (on your ~/.tool-versions file)
asdf global cifuzz latest

# Now cifuzz commands are available
cifuzz --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/bertschneider/asdf-cifuzz/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Norbert Schneider](https://github.com/bertschneider/)
