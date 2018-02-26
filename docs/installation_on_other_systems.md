# Deploying EasyBuild on random servers


## Pre-requisites

This environment installs in `/apps/easybuild`, therefore it's a good idea to have `/apps` as a separate filesystem with ample space. We have example in ansible-inventory repo for that filesystem.

The setup also relies on the availability of __hpcadmin__ group, which is provided by our LDAP. 

## Installation


* Initial packages

_we need environment modules for module support, and libibverbs-devel for the goolf toolchain_

  * openSUSE

```
zypper -n in Modules libibverbs-devel python-setuptools
```
  * CentOS

```
yum -y install environment-modules libibverbs-devel python-setuptools
```


* Post setup

As __root__

  * prepare directories

```
mkdir -p /apps
chgrp hpcadmin /apps
chmod g+ws /apps
setfacl -R -m g:hpcadmin:rwX /apps
setfacl -R -m d:g:hpcadmin:rwX /apps
```

As any of the users in __hpcadmin__ group:

  * Check out the VBI easybuild repo

```
git clone --shared https://devlab.vbi.vt.edu/HPC/easybuild.git /apps/easybuild
```

  * link basic scripts to allow loading of EasyBuild

```
mkdir -p /apps/modulefiles/site/local
ln -sf /apps/easybuild/modules/setup/local /apps/modulefiles/site/local/easybuild
sudo ln -sf /apps/easybuild/config/profile.d/* /etc/profile.d/
```

  * either log out or source the new module

```
source /etc/profile.d/easybuild-modules.sh
```

  * install EasyBuild

```
module load site/local/easybuild/hpcadmin
newgrp hpcadmin
umask 002
curl -O https://raw.githubusercontent.com/hpcugent/easybuild-framework/develop/easybuild/scripts/bootstrap_eb.py
python bootstrap_eb.py $EASYBUILD_INSTALLPATH_SOFTWARE
rm bootstrap_eb.py
module load EasyBuild
```

Done!

Now you can use EasyBuild on this system.

## Using EasyBuild

* As one of the members of `hpcadmin` group, when installing software globally to `/apps/easybuild`:

```
module load site/local/easybuild/hpcadmin
module load EasyBuild
```

* As a regular user who wants to use global EasyBuild installation, and install additional things locally in `~/easybuild/`:

```
module load site/local/easybuild/setup
module load EasyBuild
```

