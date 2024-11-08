# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test vyxal2 https://github.com/lyxal/asdf-vyxal2.git "vyxal2 --help"
```

Tests are automatically run in GitHub Actions on push and PR.
