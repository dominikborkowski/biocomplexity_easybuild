

# Copypasta instructions for EasyBuild

## Step 1 - login and environment setup

1. Login to the cluster of your choice as a member of the hpcadm group.
2. Clean up environment specific to your cluster:

* haswell

```
newgrp hpcadmin
module unload site/haswell/easybuild/setup
module unload gcc
module load site/haswell-haswell/easybuild/hpcadmin
umask 002
module load EasyBuild
unset SSH_ASKPASS
unset DISPLAY
```

* discovery

```
newgrp hpcadmin
umask 002
module unload site/discovery/easybuild/setup
module load site/discovery-sandy_bridge/easybuild/hpcadmin
module load EasyBuild
unset SSH_ASKPASS
unset DISPLAY
```

* orion

```
newgrp hpcadmin
umask 002
module unload site/orion/easybuild/setup
module load site/orion-broadwell/easybuild/hpcadmin
module load /apps/easybuild/modules/setup/orion-broadwell/hpcadmin
module load EasyBuild
unset SSH_ASKPASS
unset DISPLAY
```

* pegasus

```
newgrp hpcadmin
umask 002
module unload site/pegasus/easybuild/setup
module load site/pegasus-sandy_bridge/easybuild/hpcadmin
module load EasyBuild
unset SSH_ASKPASS
unset DISPLAY
```

## Step 2 - checkout latest changes

Here we make sure we have the latest version of our repo:

```
cd /apps/easybuild
git pull
```

## Step 3 - search and install new software

* search:
```
eb -S bioconductor
```
* dry-run:
```
eb -D R-bundle-Bioconductor-3.8-foss-2018b-R-3.5.1.eb
```
* install:
```
eb R-bundle-Bioconductor-3.8-foss-2018b-R-3.5.1.eb
```

Important notes:

* Our primary toolchain is **foss**. Do not attempt installing items from **intel**, **iomkl**, nor **goolf**


## Step 4 - commit changes

```
cd /apps/easybuild
git add .
git commit -m 'installed/upgraded X version Y on Z'
git push
```
