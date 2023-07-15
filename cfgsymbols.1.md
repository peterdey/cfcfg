% cfgsymbols(1) Version 1 | Print a symbol table of Kconfig items and their prompts
% Paul Gover
% June 2023

# NAME
 
cfgsymbols - Create a file of kernel Kconfig symbols and their prompts

# SYNOPSIS

**cfgsymbols** _outputfilepath_ [_kernelsourcepath_]

# DESCRIPTION

Scan a kernel source directory tree for Kconfig files,
and extract configuration symbols and the associated prompt.
Kconfig files define the prompts and menus used by the Linux kernel
`make menuconfig` and similar configurator commands.

The resulting file contains lines in the form:

| SYMBOL_NAME=prompt string

or, if the configuration item has no prompt
(that is, it is set internally by the kernel configurator):

| SYMBOL_NAME

Note that **cfgsymbols** removes the prefix `CONFIG_`.

If no _kernelsourcepath_ is specified, it defaults to /usr/src/linux.
If must be either a source directory or a build directory with a link named "source" pointing to
its source.

By default, **cfgsymbols** collects symbols for the system architecture default for the source or build.
Collect symbols for other architectures by setting the *ARCH* environment variable.

# OPTIONS

None

# NOTES

**cfgsymbols** output is intended for use as the symbol table for `cfcfg`.

**cfgsymbols** collects many non-architecture-dependent symbols
from other directories in the source tree.
In total, there are around 16,000 symbols in the kernel configuration
for x86.
The *ARCH* specification removes large numbers of duplicate symbols,
possibly with different prompts, for the various architectures.

Uses `file`, `gawk`, `make` and `mktemp`.  It might not work with other `awk` implementations.
In Gentoo, these come from file, gawk, make and coreutils packages.
Coded in shell script and awk, tested with `dash` and `bash`,
and should work with any POSIX compliant shell.

# ENVIRONMENT

**ARCH**

:	the architecture -- that is, the subdirectory of _kernelsource_/arch
	for which you wish to collect symbols, such as x86, arm64, mips, etc.

# SEE ALSO

**cfcfg(1)**
