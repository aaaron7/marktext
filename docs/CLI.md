# Command Line Interface

```
Usage: marktext [commands] [path ...]

  Available commands:

        --debug                   Enable debug mode
        --safe                    Disable plugins and other user configuration
    -n, --new-window              Open a new window on second-instance
        --user-data-dir           Change the user data directory
        --disable-gpu             Disable GPU hardware acceleration
    -v, --verbose                 Be verbose
        --version                 Print version information
    -h, --help                    Print this help message
```

`marktext` should point to your installation of MarkText. The exact location will vary from platform to platform. On macOS, `./build.sh` now installs a `mark` launcher automatically after a successful build and app copy, so you can run:

```sh
mark .
mark README.md
mark docs
```

If you want a custom location, set `MARKTEXT_CLI_PATH=/your/path/mark` before running `./build.sh`.

You can also create a manual alias like:

```sh
alias marktext="/Applications/MarkText.app/Contents/MacOS/MarkText"
```
