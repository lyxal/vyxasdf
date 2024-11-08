<div align="center">

# vyxasdf [![Build](https://github.com/lyxal/vyxasdf/actions/workflows/build.yml/badge.svg)](https://github.com/lyxal/vyxasdf/actions/workflows/build.yml) [![Lint](https://github.com/lyxal/vyxasdf/actions/workflows/lint.yml/badge.svg)](https://github.com/lyxal/vyxasdf/actions/workflows/lint.yml)

[vyxal](https://github.com/vyxal/vyxal) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [vyxasdf  ](#vyxasdf--)
- [Contents](#contents)
- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `poetry` for building vyxal from source.


# Install

Plugin:

```shell
asdf plugin add vyxal
# or
asdf plugin add vyxal https://github.com/lyxal/vyxasdf.git
```

vyxal2:

```shell
# Show all installable versions
asdf list-all vyxal

# Install specific version
asdf install vyxal latest

# Set a version globally (on your ~/.tool-versions file)
asdf global vyxal latest

# Now vyxal commands are available
vyxal '' 'h'
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).


# License

See [LICENSE](LICENSE) © [lyxal](https://github.com/lyxal/)