<div align="center">

# asdf-vyxal2 [![Build](https://github.com/lyxal/asdf-vyxal2/actions/workflows/build.yml/badge.svg)](https://github.com/lyxal/asdf-vyxal2/actions/workflows/build.yml) [![Lint](https://github.com/lyxal/asdf-vyxal2/actions/workflows/lint.yml/badge.svg)](https://github.com/lyxal/asdf-vyxal2/actions/workflows/lint.yml)

[vyxal2](https://github.com/lyxal/vyxasdf) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add vyxal2
# or
asdf plugin add vyxal2 https://github.com/lyxal/asdf-vyxal2.git
```

vyxal2:

```shell
# Show all installable versions
asdf list-all vyxal2

# Install specific version
asdf install vyxal2 latest

# Set a version globally (on your ~/.tool-versions file)
asdf global vyxal2 latest

# Now vyxal2 commands are available
vyxal2 --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/lyxal/asdf-vyxal2/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [lyxal](https://github.com/lyxal/)
