# A library for Bash scripts

This repository contains a library of reusable Bash functions that can
be sourced and used in Bash scripts.

The library follows the Google [Shell Style
Guide](https://google.github.io/styleguide/shellguide.html) and is
checked with [ShellCheck](https://www.shellcheck.net/).

## Usage

To use the functions in your Bash scripts, source the library file.

In the following example we look for the library file path first in the
environment variable `BASH_SCRIPTS_LIB_PATH`, then under the directory
in `XDG_DATA_HOME` (typically `${HOME}/.local/share`, see the [XDG Base
Directory
Specification](https://specifications.freedesktop.org/basedir-spec/latest/#variables)):

```bash
source "${BASH_SCRIPTS_LIB_PATH:-${XDG_DATA_HOME:?}/bash-scripts-lib/lib.sh}" \
  || exit
```

The example below also looks in `/usr/local/share/bash-scripts-lib` and
provides a useful error message if the dependency is missing:

```bash
{ test -n "${BASH_SCRIPTS_LIB_PATH:-}" && test -r "$_" && source "$_"; } \
  || { test -n "${XDG_DATA_HOME:-}" && test -r "$_/bash-scripts-lib/lib.sh" \
         && source "$_"; } \
  || { test -r "/usr/local/share/bash-scripts-lib/lib.sh" && source "$_"; } \
  || { printf '%s\n' "$0: ERROR: Missing dependency: bash-scripts-lib" >&2
       exit 1; }
```

## Features

### Template

A [Bash script template](template) is included, which demonstrates
command-line argument parsing and message logging.

### Message logging

The format of log messages can be changed by setting the environment
variable `BASH_SCRIPTS_LIB_LOG_STYLE`. Set this variable to `logfile` to
include timestamps.

When `BASH_SCRIPTS_LIB_LOG_STYLE` is not set:

```bash
$ ./template -v test
template: info: Example informative message.
template: info: Done.
```

When `BASH_SCRIPTS_LIB_LOG_STYLE` is set to `logfile`:

```bash
$ BASH_SCRIPTS_LIB_LOG_STYLE=logfile ./template -v test
2009-08-14 13:37:00.000 INFO  template: Example informative message.
2009-08-14 13:37:00.017 INFO  template: Done.
```
