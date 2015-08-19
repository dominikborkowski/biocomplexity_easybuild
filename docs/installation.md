# VBI EasyBuild Installation

This basic document outlines how to install EasyBuild and take advantage of the directory structure developed for VBI HPC resources.

The main goals behind this setup are:

* Provide pre-configured EasyBuild environment and tools for both end users and HPC system administrators.
* Allow sysadmins to maintain global repositories, while giving users ability to install their own software.
* Use directory structure that works when home directories and shared app locations are shared across multiple different clusters and architectures


## Directory Structure

### GLobal directories

Everything in these directories is managed by system administrators, and it's available for all end-users.

* `/apps/modulefiles/`
    * `/site/`
        * `/<CLUSTER>-<ARCH>/`
            * `/easybuild/` - symlink to `/apps/easybuild/modules/setup/<CLUSTER>-<ARCH>`
        * `/<CLUSTER>/` - _symlink to the default ARCH on a given CLUSTER_
* `/apps/easybuild/` - _central location for all EasyBuild files, stored in a single git repository_
    * `/config/`
        * `/<CLUSTER>-<ARCH>` - _UNUSED, but reserved for the future use of config files_
    * `/modules/`
        * `/<CLUSTER>_<ARCH>/` - _automatically generated modules for software installed via easybuild_
        * `/setup/` - _modules for setting up easybuild environment_
         	* `/<CLUSTER>-<ARCH>/`
                * `/setup` - _end-user module for setting up easybuild variables specific to this <CLUSTER>-<ARCH>_
                * `/hpcadmin` - _sysadmin module for this <CLUSTER>-<ARCH>install options_
            * `/<CLUSTER>/` - _symlink to the default ARCH on a given CLUSTER_
    * `/ebfiles_repo/` - _automatically generated easyconfigs_
        * `/<CLUSTER>/` - _symlink to the default ARCH on a given CLUSTER_
        * `/<CLUSTER>-<ARCH>/` - _3rd in ROBOT path_
    * `/ebfiles_repo-<org>/` - _custom easyconfigs maintained by our <org>_
        * `/<CLUSTER>`  - _symlink to the default ARCH on a given CLUSTER_
        * `/<CLUSTER>-<ARCH>/` _1st in ROBOT path_
            * `/<software_name>`
        * `/generic/` - _2nd in ROBOT path_
    * `/software/` - _destination for installed software_
        * `/<CLUSTER>-<ARCH>/`
    * `/sources/` - _shared across all easybuild instances to minimize download times_


### Local directories

These directories are optional, and are created automatically when a user uses EasyBuild to install software. All these are automatically created with exception of `~/easybuild/ebfiles_repo-custom/`.

* `~username/`
    * `/easybuild/` - _central location for all EasyBuild files_
        * `/config/`
            * `/<CLUSTER>-<ARCH>` - _UNUSED, but reserved for the future use of config files_
        * `/modules/`
         	* `/<CLUSTER>_<ARCH>/` - _automatically generated modules for software installed via easybuild_
        * `/ebfiles_repo/` - _automatically generated easyconfigs_
            * `/<CLUSTER>-<ARCH>/` - _3rd in ROBOT path_
        * `/ebfiles_repo-custom/` - _custom easyconfigs maintained by the end user_
            * `/<CLUSTER>-<ARCH>/` _1st in ROBOT path_
                * `/<software_name>`
            * `/generic/` - _2nd in ROBOT path_
        * `/software/` - _destination for installed software_
            * `/<CLUSTER>-<ARCH>/`
        * `/sources/` - _shared across all easybuild instances to minimize download times_

## Installation

### Envrionment setup modules

To utilize directory structure, detailed in the previous section, we have two environment modules set up for each site/cluster/architecture combination:

* `/easybuild/modules/setup/<cluster>-<arch>/hpcadmin` - for use by sysadmins only
* `/easybuild/modules/setup/<cluster>-<arch>/setup` - for use by all end users

Please see Appendix showing sample files


### Install steps

Once the `hpcadmin` module is in its proper place, according to site/cluster/arch structure, and variables inside are adjusted to match that combination, we can install EasyBuild:

```
newgrp hpcadmin
umask 002
module load site/shadowfax-sandy_bridge/easybuild/hpcadmin
curl -O https://raw.githubusercontent.com/hpcugent/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py
python bootstrap_eb.py $EASYBUILD_INSTALLPATH_SOFTWARE
rm bootstrap_eb.py
module load EasyBuild
```

## Appendix

### Environment modules

#### `setup`

```
#%Module1.0#############################################################################################################
###
### custom EasyBuild setup module for VBI HPC systems
### This module is intended for end users. ~/easybuild files take precedence over global ones.
###
### originally based on work done by Jülich Supercomputing Centre (JSC)

#######################################################################################################################
# global configuration

# set up paths for the global software repository
set global "/apps/easybuild"
# set our site
set site "shadowfax"
# set our organization
set org "vbi"
# set our architecture
set arch "sandy_bridge"

# set local location of EasyBuild
set local "~$::env(USER)/easybuild"

# # permissions and ownerships
# set easybuild_umask "002"
# set easybuild_set_gid_bit "1"
# set easybuild_sticky_bit "1"
# set easybuild_group_writable_installdir "1"

# end of global configuration
#######################################################################################################################


# help functions
proc ModulesHelp { } {
  puts stderr "  This module will load the required environment to prepare for managing software installations"
  puts stderr "  with EasyBuild on $site with $arch architecture in $local directory. \n"
}

module-whatis "Module for setting up EasyBuild development end-user environment on $site with $arch."

# start the module
if { [ module-info mode load ] } {
    puts stderr "\nPreparing EasyBuild environment for $site with $arch in $local directory: \n"
}


# what's the location of our dummy module, which indicates that we're installing EasyBuild
# set easybuild_install_module "test/dom/EasyBuild-install"

# paths
if { [ module-info mode load ] } {
    puts stderr "* Setting environment variables for EasyBuild's directories"
}

# originally started by providing EASYBUILD_PREFIX, then switched to more split view
# setenv EASYBUILD_PREFIX $global/$site-$arch
# setenv EASYBUILD_INSTALLPATH $global/$site-arch

# what configuration files should be loaded and in which order:
# - settings in last file take precedence over settings in earlier files
# - each config file listed must exist
# - environment variables override options from config files
# setenv EASYBUILD_CONFIGFILES $global/config/generic/config.cfg,$global/config/$site-$arch/config.cfg,$local/config/generic/config.cfg,$local/config/$site-$arch/config.cfg

setenv EASYBUILD_INSTALLPATH_SOFTWARE $local/software/$site-$arch
setenv EASYBUILD_INSTALLPATH_MODULES $local/modules/$site-$arch
setenv EASYBUILD_SOURCEPATH $local/sources
setenv EASYBUILD_REPOSITORYPATH $local/ebfiles_repo/$site-$arch
setenv EASYBUILD_ROBOT $local/ebfiles_repo-custom/shadowfax-sandy_bridge:$local/ebfiles_repo-custom/generic:$local/ebfiles_repo/shadowfax-sandy_bridge:$global/ebfiles_repo-vbi/shadowfax-sandy_bridge:$global/ebfiles_repo-vbi/generic:$global/ebfiles_repo/shadowfax-sandy_bridge
# use /dev/shm for building software
setenv EASYBUILD_BUILDPATH /dev/shm/$::env(USER)/build

# # permissions
# if { [ module-info mode load ] } {
#     puts stderr "* Setting environment variables for EasyBuild's permissions"
# }
# setenv EASYBUILD_UMASK $easybuild_umask
# setenv EASYBUILD_SET_GID_BIT $easybuild_set_gid_bit
# setenv EASYBUILD_STICKY_BIT $easybuild_sticky_bit
# setenv EASYBUILD_GROUP_WRITABLE_INSTALLDIR $easybuild_group_writable_installdir

# global options
if { [ module-info mode load ] } {
    puts stderr "* Setting environment variables for EasyBuild's global options"
}
setenv EASYBUILD_MODULES_TOOL EnvironmentModulesC
setenv EASYBUILD_REPOSITORY FileRepository
setenv EASYBUILD_MODULE_NAMING_SCHEME EasyBuildMNS
# setenv EASYBUILD_ALLOW_MODULES_TOOL_MISMATCH 1

# if { [ module-info mode load ] } {
#     puts stderr "* Setting environment variables for loading EasyBuild module"
# }

# allow EasyBuild to find the modulecmd binary directly
append-path     PATH    "$::env(MODULESHOME)/bin"

# make sure our custom modules are earlier in the MODULEPATH than global VBI ones
append-path MODULEPATH  "~$::env(USER)/easybuild/modules/$site-$arch/all"

# make sure we can load EasyBuild module manually
append-path MODULEPATH  "$global/modules/$site-$arch/all"

#  this section is not used, since we may be triggering an issue in EasyBuild
# # if EasyBuild-install module is loaded, then we assume we are trying to install EasyBuild
# # otherwise, we are going to load the EasyBuild module
# if { [ is-loaded $easybuild_install_module ] } {
#     if { [ module-info mode load ] } {
#         puts stderr "* EasyBuild-install module is loaded - we're ready for initial EasyBuild install"
#     }
# } else {
#     if { [ module-info mode load ] } {
#         puts stderr "* Loading EasyBuild module"
#     }
#     # make sure we can load EasyBuild module
#     module use $global/modules/all/Core
#     # load the EasyBuild module
#     module load EasyBuild
# }

#  final empty line
if { [ module-info mode load ] } {
    puts stderr "* End of EasyBuild init procedure \n"
    puts stderr "- To use EasyBuild system for compiling new software please run: \n"
    puts stderr "module load EasyBuild"
    puts stderr ""
    puts stderr "- To list all available modules please use: module av"
    puts stderr ""
}


# if { [ module-info mode load ] } {
#     puts stderr "* debug \n"
#     puts stderr "- ModulesCurrentModulefile is $ModulesCurrentModulefile \n"
#     puts stderr "- foobar is foobar \n"
# }

#######################################################################################################################
```

#### `hpcadmin`

```
#%Module1.0#############################################################################################################
###
### custom EasyBuild setup module for VBI HPC systems
### This module is intended for admin users who have write access to global repository
###
### originally based on work done by Jülich Supercomputing Centre (JSC)

#######################################################################################################################
# global configuration

# set up paths for the global software repository
set global "/apps/easybuild"
# set our site
set site "shadowfax"
# set our organization
set org "vbi"
# set our architecture
set arch "sandy_bridge"


# # permissions and ownerships
set easybuild_umask "002"
set easybuild_set_gid_bit "1"
set easybuild_sticky_bit "1"
set easybuild_group_writable_installdir "1"

# end of global configuration
#######################################################################################################################


# help functions
proc ModulesHelp { } {
  puts stderr "  This module will load the required environment to prepare for managing software installations"
  puts stderr "  with EasyBuild on $site with $arch architecture in $global directory. \n"
}

module-whatis "Module for setting up EasyBuild development admin environment on $site with $arch."

# start the module
if { [ module-info mode load ] } {
    puts stderr "\nPreparing EasyBuild environment for $site with $arch in $global directory: \n"
}


# what's the location of our dummy module, which indicates that we're installing EasyBuild
# set easybuild_install_module "test/dom/EasyBuild-install"

# paths
if { [ module-info mode load ] } {
    puts stderr "* Setting environment variables for EasyBuild's directories"
}

# originally started by providing EASYBUILD_PREFIX, then switched to more split view
# setenv EASYBUILD_PREFIX $global/$site-$arch
# setenv EASYBUILD_INSTALLPATH $global/$site-arch

# what configuration files should be loaded and in which order:
# - settings in last file take precedence over settings in earlier files
# - each config file listed must exist
# - environment variables override options from config files
# setenv EASYBUILD_CONFIGFILES $global/config/generic/config.cfg,$global/config/$site-$arch/config.cfg,$local/config/generic/config.cfg,$local/config/$site-$arch/config.cfg

setenv EASYBUILD_INSTALLPATH_SOFTWARE $global/software/$site-$arch
setenv EASYBUILD_INSTALLPATH_MODULES $global/modules/$site-$arch
setenv EASYBUILD_SOURCEPATH $global/sources
setenv EASYBUILD_REPOSITORYPATH $global/ebfiles_repo/$site-$arch
setenv EASYBUILD_ROBOT $global/ebfiles_repo-vbi/shadowfax-sandy_bridge:$global/ebfiles_repo-vbi/generic:$global/ebfiles_repo/shadowfax-sandy_bridge
# use /dev/shm for building software
setenv EASYBUILD_BUILDPATH /dev/shm/$::env(USER)/build

# permissions
if { [ module-info mode load ] } {
    puts stderr "* Setting environment variables for EasyBuild's permissions"
}
setenv EASYBUILD_UMASK $easybuild_umask
setenv EASYBUILD_SET_GID_BIT $easybuild_set_gid_bit
setenv EASYBUILD_STICKY_BIT $easybuild_sticky_bit
setenv EASYBUILD_GROUP_WRITABLE_INSTALLDIR $easybuild_group_writable_installdir

# global options
if { [ module-info mode load ] } {
    puts stderr "* Setting environment variables for EasyBuild's global options"
}
setenv EASYBUILD_MODULES_TOOL EnvironmentModulesC
setenv EASYBUILD_REPOSITORY FileRepository
setenv EASYBUILD_MODULE_NAMING_SCHEME EasyBuildMNS
# setenv EASYBUILD_ALLOW_MODULES_TOOL_MISMATCH 1

# if { [ module-info mode load ] } {
#     puts stderr "* Setting environment variables for loading EasyBuild module"
# }

# allow EasyBuild to find the modulecmd binary directly
append-path     PATH    "$::env(MODULESHOME)/bin"

# # make sure our custom modules are earlier in the MODULEPATH than global VBI ones
# append-path MODULEPATH  "~$::env(USER)/easybuild/modules/$site-$arch/all"

# make sure we can load EasyBuild module manually
append-path MODULEPATH  "$global/modules/$site-$arch/all"

#  this section is not used, since we may be triggering an issue in EasyBuild
# # if EasyBuild-install module is loaded, then we assume we are trying to install EasyBuild
# # otherwise, we are going to load the EasyBuild module
# if { [ is-loaded $easybuild_install_module ] } {
#     if { [ module-info mode load ] } {
#         puts stderr "* EasyBuild-install module is loaded - we're ready for initial EasyBuild install"
#     }
# } else {
#     if { [ module-info mode load ] } {
#         puts stderr "* Loading EasyBuild module"
#     }
#     # make sure we can load EasyBuild module
#     module use $global/modules/all/Core
#     # load the EasyBuild module
#     module load EasyBuild
# }

#  final empty line
if { [ module-info mode load ] } {
    puts stderr "* End of EasyBuild init procedure \n"
    puts stderr "- To use EasyBuild system for managing software please run: \n"
    puts stderr "newgrp hpcadmin"
    puts stderr "umask 002"
    puts stderr "module load EasyBuild"
    puts stderr ""
}


# if { [ module-info mode load ] } {
#     puts stderr "* debug \n"
#     puts stderr "- ModulesCurrentModulefile is $ModulesCurrentModulefile \n"
#     puts stderr "- foobar is foobar \n"
# }

#######################################################################################################################
```
