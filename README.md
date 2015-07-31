# VBI HPC EasyBuild


## Introduction

This is an EasyBuild setup for VBI HPC resources. It provides a way to easily maintain large number of scientific software and make it accessible to our users.

This directory is typically found in `/apps/easybuild`. The git repository contains only setup files, basic structure, and module files. Module files include both maintained by VBI, and ones automatically generated by EasyBuild.

 Eventually this setup will be detailed on our wiki: [VBI wiki - HPC Applications](https://collaboration.vbi.vt.edu/display/HPC/30+-+Applications)


## Basic usage

### end users

* load basic modules:

```
module load site/shadowfax/easybuild/setup
```
* list available modules:

```
module avail
```

### software maintainers

To deploy new software

* set up your environment

```
newgrp hpcadmin
umask 002
module load site/shadowfax/easybuild/setup
module load EasyBuild
```
* basic `eb` usage:
  * search for cufflinks
  ```
  eb -S cufflinks
  ```
  * install cufflinks
  ```
  eb Cufflinks-2.2.1-goolf-1.4.10.eb --robot
  ```

* review and commit your changes after installing software:

```
cd /apps/easybuild
git status
git add <appropriate dirs or files>
git commit -m 'installed cufflinks 2.2.1'
```


## Structure