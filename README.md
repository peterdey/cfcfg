# CFCFG - tools for comparing Linux kernel configurations

## Why

If you work with custom Linux kernels, you may need to compare two configurations.
For example, perhaps something broke after a change, or perhaps someone with a similar system
has a problem and you want to identify the difference between the configurations.

The Linux kernel source comes with a script `diffconfig` that provides a stripped-down
listing of changed items in alphabetical order, which lacks context compared to the menu-based
Linux `make menuconfig` tools.

**cfcfg** provides a more user-friendly comparison, using comments, indentation and colour
to reflect the organization of configuration items into menus and sub-menus.
It can optionally add the prompt text from the menus to annotate the configuration items.
Thus, where `diffconfig` might produce a listing including the lines:
```
 LOCALVERSION "-git" -> "-hp"
 LOCKD y -> m
 LOGO_LINUX_MONO n -> y
 LOG_CPU_MAX_BUF_SHIFT 13 -> 12
 LZ4_COMPRESS m -> y
 LZ4_DECOMPRESS m -> y
 MEDIA_DIGITAL_TV_SUPPORT y -> n
 MEDIA_SUPPORT y -> m
 MOUSE_APPLETOUCH n -> y
 MOUSE_BCM5974 n -> y
 MOUSE_PS2 y -> m
 MOUSE_SYNAPTICS_I2C n -> y
 MOUSE_SYNAPTICS_USB n -> y
 MSDOS_FS m -> n
 NETFILTER_INGRESS n -> y
```
**cfcfg** would produce:
```
# Linux/x86 6.4.3 Kernel Configuration ---> # Linux/x86 6.4.3 Kernel Configuration
   # General setup
|      LOCALVERSION="-git"--->"-hp"      # Local version - append to kernel release
|      DEFAULT_HOSTNAME="ryzen"--->"hp"          # Default hostname
+      CROSS_MEMORY_ATTACH=y     # Enable process_vm_readv/writev syscalls
+      AUDIT=y   # Auditing support
|      LOG_CPU_MAX_BUF_SHIFT=13--->12    # CPU kernel log buffer size contribution
-      BLK_CGROUP=y      # IO controller
-      CGROUP_FREEZER=y          # Freezer controller
+      CPUSETS=y         # Cpuset controller
-      CGROUP_DEVICE=y   # Device controller
+      PROC_PID_CPUSET=y         # Include legacy /proc/<pid>/cpuset file
+      TIME_NS=y         # TIME namespace
|      INITRAMFS_SOURCE="initramfs_list"--->"initramfs.list"     # Initramfs source
-      RD_ZSTD=y         # Support initial ramdisk/ramfs compressed using ZSTD
   # Processor type and features
-      X86_X2APIC=y      # Support x2apic
|      NR_CPUS=32--->4   # Maximum number of CPUs
       # Performance monitoring
-          PERF_EVENTS_INTEL_RAPL=y      # Intel/AMD rapl performance events
```
## How

**cfcfg** is a POSIX shell script that uses GNU awk to preprocess kernel configuration files,
passes the results to GNU diff to produce a comparison, and finally tidies the results
with more awk.  Linux kernel `make` configuration tools inset comments into the files
that reflect menu hierarchy, and the awk scripts use these to construct the relevent context around
changed values.

**cfgsymbols** is another POSIX shell script that again uses GNU awk to collect the
symbol names and the associated prompt text from the Linux kernel `Kconfig` files
which define the menu system (and much more).  The resulting file typically contains
around 16,000 configuration items and associated prompts.  **cfcfg** will use this file
if available to annotate the items listed.

## Using the tools

Running **cfcfg** in the simplest way is:

|	cfcfg _oldconfig_ _newconfig_

such as:

|	cfcfg .config.old .config

which will produce a colourful listing at the terminal.
You can of course redirect the output to file or pager program like `less`.
In these cases, the file is uncoloured unless you also specify the _-c_ option:

|	cfcfg -c .config.old .config | less

Optionally, create a symbol table using **cfgsymbols** - for example:

|	cfgsymbols kernel-6.4.symbols /usr/src/linux-6.4.3

Note that this is quite slow process, as it has to find and parse a large number of
`Kconfig` files.
Note also that you need to update the symbol table for new kernel releases,
as they often get new symbols, for example for new hardware.  They may also drop
old symbols, in which case you might wish to merge new and old symbol tables.
As the files are sorted, you can GNU sort to do this.  For example:

|	sort -m -k 1,1 -t = old.symbols kernel-6.4.symbols > new.symbols

Tell cfcfg about the symbol table using the _CFGSYMBOLS_ environment variable:

|	CFGSYMBOLS=new.symbols cfcfg /boot/config-6.3.1 /boot/config-6.4.3

## Documentation

See the man pages for each tool:

- man 1 cfcfg
- man 1 cfgsymbols
