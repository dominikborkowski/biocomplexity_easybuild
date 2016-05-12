# Building custom software with EasyBuild


## Commonly used commands

Please see [latest documentation](http://easybuild.readthedocs.org/en/latest/Using_the_EasyBuild_command_line.html) for detailed information on using EasyBuild commands.

* Search for software named 'sed'. This will produce a list of known __easyconfigs__:

```
eb -S sed
```
* sample output

```
dom@sfxlogin3:~> eb -S sed
== temporary log file in case of crash /tmp/eb-uXHCPk/easybuild-dI_JPt.log
== Searching (case-insensitive) for 'sed' in /home/dom/easybuild/ebfiles_repo-custom/shadowfax-sandy_bridge
== Searching (case-insensitive) for 'sed' in /home/dom/easybuild/ebfiles_repo-custom/generic
== Searching (case-insensitive) for 'sed' in /home/dom/easybuild/ebfiles_repo/shadowfax-sandy_bridge
== Searching (case-insensitive) for 'sed' in /apps/easybuild/ebfiles_repo-vbi/shadowfax-sandy_bridge
== Searching (case-insensitive) for 'sed' in /apps/easybuild/ebfiles_repo-vbi/generic
== Searching (case-insensitive) for 'sed' in /apps/easybuild/ebfiles_repo/shadowfax-sandy_bridge
== Searching (case-insensitive) for 'sed' in /apps/easybuild/software/shadowfax-sandy_bridge/EasyBuild/2.2.0/lib64/python2.6/site-packages/easybuild_easyconfigs-2.2.0-py2.6.egg/easybuild/easyconfigs
CFGS1=/apps/easybuild/software/shadowfax-sandy_bridge/EasyBuild/2.2.0/lib64/python2.6/site-packages/easybuild_easyconfigs-2.2.0-py2.6.egg/easybuild/easyconfigs
 * $CFGS1/q/Qt/Qt-4.8.5_ictce-qUnused.patch
 * $CFGS1/q/Qt/Qt-4.8.6_icc-qUnused.patch
 * $CFGS1/s/sed/sed-4.2.2-goolf-1.4.10.eb
 * $CFGS1/s/sed/sed-4.2.2-ictce-5.3.0.eb
== temporary log file(s) /tmp/eb-uXHCPk/easybuild-dI_JPt.log* have been removed.
== temporary directory /tmp/eb-uXHCPk has been removed.
```

* Show all the required dependencies for `sed-4.2.2-goolf-1.4.10.eb` easyconfig. Items marked with `[x]` are already present and will not need to be compiled:

```
eb sed-4.2.2-goolf-1.4.10.eb --dry-run
```

* To install sed provided by an available easyconfig run the following command. `--robot` option takes care of installing or using all the necessary dependencies:

```
eb sed-4.2.2-goolf-1.4.10.eb --robot
```

 * VBI currently supports the following toolchains:
    * `goolf` (preferred version 1.7.20)
    * `gompi`

* If there is a newer, or older, version of sed that you may want instead, we can use `--try-software-version=N` option:

```
eb sed-4.2.2-goolf-1.4.10.eb --robot --try-software-version=4.2.1
```

* To build this software against a different toolchain (collection of compilers and libraries) you can specify it via one of the following options:

	* build with specific toolchain and version:

```
eb sed-4.2.2-goolf-1.4.10.eb --try-toolchain=goolf,1.7.20
```

* build with the latest version of specific toolchain


```
eb sed-4.2.2-goolf-1.4.10.eb --try-toolchain-name=gompi

```

* build with a specific version of the same toolchain:

```
eb sed-4.2.2-goolf-1.4.10.eb --try-toolchain-version=1.7.20

```

*  Search and build software by name:

```
eb --software-name=sed --robot
```

* Chances are there may be more than one toolchain available, so specify it:

```
eb --software-name=sed --robot --try-toolchain-name=goolf
```

* Try building a specific version of sed:

```
eb --software-name=sed --robot --try-toolchain-name=goolf --try-software-version=4.2.1
```

### Sample scenarios


More to come!

### Advanced options


* If you need to build software which needs restricted access, specific to a group, use the following option.
This will do two things:
  * set more restrictive permissions on the installed software dirs/files
  * verify whether the resulting files are owned by this group
Since EasyBuild cant' change group by itself, we need to do it manually before running it:
```
newgroup <group_name>
eb --group=<group_name> [...]
```

* List known easyblocks, which are methods for installing software:

```
eb --list-easyblocks
```





