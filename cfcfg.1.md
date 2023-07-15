% cfcfg(1) Version 1 | Show changes between two kernel configuration files
% Paul Gover

SYNOPSIS
========

**cfcfg** \[**-c**] \[**-m**] \[**-w _nnn_**] _oldcondfigfile_ _newconfigfile_

DESCRIPTION
===========

Produce a succinct comparison of two kernel config files,
each of which MUST be the unmodified .config file from the kernel "make" configurator.
Changes such as sorting or manual editing will probably cause erroneous and voluminous output.
**cfcfg** retains contextual information comments such as `Processor options`, `Device drivers`,
including nested contexts, and indents the output accordingly.

"Succinct" means that all unset items and irrelevant comments get stripped from the output,
as are the `CONFIG_` prefixes to setting names, and by default all `unset` items.

In the output,
added settings are prefixed by `+`, and coloured green if output to a terminal,
whereas deleted settings are prefixed `-` and coloured blue.
Changed settings are prefixed `|` and coloured white,
apart from the actual values, which are coloured yellow.
**cfcfg** omits the colours when output is redirected to a file or pipeline,
unless overridden by the **-c** option.

**cfcfg** can also be used to pretty-print a succinct config file extract
by making one of the comparison config files `/dev/null`.

OPTIONS
=======

**-c**

: Force output colouring when output to file or pipe.

**-m**

: Treat module settings (=m) as builtin (=y) before comparison
This will remove non-functional differences.

**-u**

: Retain unset variables in the output.

**-w _nnn_**

: Width of "diff" columns used internally for the comparison.
Output lines can be up to twice this length, plus gutters and indentation,
but usually a lot less.  Default width is 80.

NOTES
=====

The output is truncated to fit the screen, but the comparison is based on all the text.
This means that the display of long lines might not reach the differences.

The indentation is based on the location of comments in the configuration files.
This is not a defined API, so the algorithm used may not always get it right.
There are missing comments such as `Bluetooth` and duplicates such as `Media drivers`.

The **-u** option treats unset items as if they had the value `unset`.
This will cause confusion should your configuration have a setting with value "unset".
Tough.

Uses `diff`, `gawk` and `mktemp`.  It might not work with other `awk` implementations.
In Gentoo, these come from diffutils, gawk and coreutils packages.
Coded in shell script, tested with `dash` and `bash`,
and should work with any POSIX compliant shell.
