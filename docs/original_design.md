
# VBI plans for using EasyBuild

## Introduction

This document outlines basic ideas of how our organization manages scientific software deployments on its HPC systems and how we could use [EasyBuild](https://github.com/hpcugent/easybuild) to improve the current process.

### About VBI

VBI is a bioinformatics research institute at Virginia Tech. Our researchers have access to both external HPC resources, provided by the university, and our own internal ones. VBI has a few clusters, with Shadowfax being our core system. 

Shadowfax is a heterogenous system, with nodes spanning Sandy Bridge, Ivy Bridge and now Haswell. It also has a range of systems with different GPGPUs, fat nodes and FPGA based nodes. Multiple storage systems are provided access to applications, home and fast scratch. All nodes have access to the same storage, under the same mount points.

### Current setup

Historically, we've managed applications using EnvironmentModulesC, with the following architecture:

* `/apps`
  * `/modulefiles`
    * `/{bio,math,devel,db,tools,other categories}`
      * `[software_name]`
        * `[1.2.3]`
  * `/packages`
    * `/{bio,math,devel,db,tools,other categories}`
      * `[software_name]`
        * `[1.2.3]/{bin,lib64,...}`
  * `/docs/`
  * `/etc/`
 

Users upon login have their modules environment `MODULEPATH` to `/cm/local/modulefiles:/cm/shared/modulefiles:/apps/modulefiles`. The first two locations are related to the BrightComputing's Cluster Manager product, responsible for provisioning systems.

In the past our system administrators and graduate research assistants have managed software installed to `/apps/packages` and manually created corresponding modules in `/apps/modulefils`. Needless to say, the process was (and continues to be) slow and error prone. With limited resources we began looking at Easybuild as means to streamline the process, both for deploying new software and cleaning up the existing packages.
 
## Easybuild integration

Here are some of my ideas on how easybuild installation could be integrated into our environment. They are based on the limited experience with EasyBuild, its documentation, and disscussions with its developers and users. The major goals include (numbering scheme does not indicate priorities):

1. end users must be able to easily view and load available modules
2. a group of users should be able to deploy new software in a shared location
3. multiple easybuild instances need to be present, to account for various clusters and their multiple architectures
4. easybuild configuration for each cluster/architecture pair should be stored in a single location, whether it's a module file or configuration
	* easybuild configurations should re-use as much code as possible
	* setup for easybuild for each cluster/architecture should be accomplished by loading a single module
5. easybuild output should be stored in single top directory, with cluster/arch subdirectory, based on the type:
	* easybuild configurations, for ease of storing in a VCS
	* easybuild modules, for ease of storing in a VCS
	* easybuild prepared software
6. there needs to be a way to easily override default easyconfigs by having ROBOT search path that first checks cluster/arch specific location, then moves onto organization's generic location, and finally to the default easyconfigs provided by easybuild
7. automatically set a unique build location for each user


### EasyBuild structure

Below is a sample structure of easybuild deployment that we would like to see.

#### legend:

* `/directory/` - directories are indicated by a trailing slash
* `/file` - files do not have trailing slashes
* `<CLUSTER>` - name of a cluster or shared compute system, eg `sfx`
* `<ARCH>` - architecture or processor family for a given system, eg: `sandy_bridge`, `ivy_bridge`, etc

#### structure

* `/apps/`
    * `/modulefiles/`
        * `/site/`
            * `/<CLUSTER>-<ARCH>/`
                * `/easybuild/`
                    * `/setup` - _module for setting up easybuild variables specific to this <CLUSTER>-<ARCH>_
                    * `/[something_else?]` - _potential module for development/install options_
            * `/<CLUSTER>/` - _symlink to the default ARCH on a given CLUSTER_
    * `/easybuild/`
        * `/config/`
            * `/<CLUSTER>-<ARCH>`
        * `/modules/`
            * `/<CLUSTER>-<ARCH>/`
            * `/<CLUSTER>` - _symlink to the defaul ARCH_
        * `/ebfiles_repo/` - _a single git repo of automatically generated easyconfigs_
            * `/<CLUSTER>/` - _symlink to the default ARCH on a given CLUSTER_
            * `/<CLUSTER>-<ARCH>/` - _3rd in ROBOT path_
        * `/ebfiles_repo-<org>/` - _a single git repo of custom easyconfigs maintained by our <org>_
            * `/<CLUSTER>`  - _symlink to the default ARCH on a given CLUSTER_
            * `/<CLUSTER>-<ARCH>/` _1st in ROBOT path_
                * `/OpenMPI`
            * `/generic/` - _2nd in ROBOT path_
        * `/software/` - _destination for installed software_
            * `/<CLUSTER>-<ARCH>/`
        * `/sources/` - _shared across all easybuild instances to minimize download times_
    * `/modules/`
        * `/<CLUSTER>_<ARCH>/`
    * `/plenv/` - _possible location for multiple perl installations and corresponding modules_
    * `/virtualenv/` - _possible location for multiple python installations and corresponding modules_

## Results

With the above design goals in mind, we've ran into some issues. We've attempted to accomplish the above plan by using two different approaches:

1. Via environment variables set in a [vbi easybuild setup module #1](https://gist.github.com/dominikborkowski/b6de7a4ca881e664d68f)
2. Via [vbi configuration file](https://gist.github.com/dominikborkowski/1121c86e65e1bda3643d) which is used by loading [vbi easybuild setup module #2](https://gist.github.com/dominikborkowski/8f174c1e755727fb354b)

### 1

_end users must be able to easily view and load available modules_

Initially the **HierarchicalMNS** structure seemed very appealing. Unfortunately, with our current environment using EnvironmentModulesC, we can't use `module spider` command, which would expose modules built with EasyBuild toolchains. We may need to fall back to the default scheme for now.

### 2

_a group of users should be able to deploy new software in a shared location_

Administrators tasked with managing software on the clusters are part of a shared group `hpcadmin`. While EasyBuild has a group setting, it's limited to erroring out, rather than forcing the group. Not sure if it's possible to take advantage of `os.setegid` function. Right now we solve it by prompting users to run `newgrp hpcadmin`.

### 3

_multiple easybuild instances need to be present, to account for various clusters and their multiple architectures_

EasyBuild has a ton of options that allow us to customize locations for various components. We can set those either via environment variables or configuration file.


### 4

_easybuild configuration for each cluster/architecture pair should be stored in a single location, whether it's a module file or configuration_

_easybuild configurations should re-use as much code as possible_

We're really hoping to achieve that. Having a single environment module that could extract cluster name and architecture from the path it would be ideal. Not sure if that's possible to achieve with EnvironmentModulesC

_setup for easybuild for each cluster/architecture should be accomplished by loading a single module_

See some notes below. We ran into problems with certain features being available only via configuration files, while others we could achieve only via environment variables.


### 5

_easybuild output should be stored in single top directory, with cluster/arch subdirectory, based on the type:_

See notes below. Seems the EasyBuild design aims to use a single top location, without breaking its subcomponents to outside locations. 

_easybuild configurations, for ease of storing in a VCS_

We use `EASYBUILD_REPOSITORYPATH` for this task. Originally we were planning to perform commits by hand; however, EasyBuild has a nice git integration, described [here](https://easybuild.readthedocs.org/en/latest/Configuration.html#easyconfigs-repo)

_easybuild modules, for ease of storing in a VCS_

We can leverage `EASYBUILD_SUBDIR_MODULES` for this; however, it seems it was designed to provide a relative location to `EASYBUILD_PREFIX`. See [Issue 105](https://github.com/hpcugent/easybuild/issues/105)

_easybuild prepared software_

We can leverage `EASYBUILD_SUBDIR_SOFTARE` for this; however, it seems it was designed to provide a relative location to `EASYBUILD_PREFIX`. See [Issue 105](https://github.com/hpcugent/easybuild/issues/105)


### 6

_there needs to be a way to easily override default easyconfigs by having ROBOT search path that first checks cluster/arch specific location, then moves onto organization's generic location, and finally to the default easyconfigs provided by easybuild_

Currently the only way to prepend the ROBOT path is via EasyBuild's configuration file. Setting EASYBUILD_ROBOT results in losing the default location. See [Issue 161](https://github.com/hpcugent/vsc-base/issues/161)

### 7 

_automatically set a unique build location for each user_

Using modules we can accomplish that via:
`setenv EASYBUILD_BUILDPATH /dev/shm/$::env(USER)/build`

However, there seems to be no equivalent method via configuration files. 

## Summary

I believe with a few small bug fixes, we will be able to refine the deployment strategy for EasyBuild, whether it's accomplished via a set of configuration files or modules. 

Once that's in place, the amount of time required to service requests for new and/or updated software will be down significantly. What's more important, introducing new architectures and clusters into our environment will be trivial, as we'll be able to replicate all of the existing software with ease.

We're also hoping that our current cluster management software eventually will provide official support and integration with EasyBuild. 
