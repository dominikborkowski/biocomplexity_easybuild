#!/bin/bash

# small script to patch easybuild, because SLES has issues
VER=3.0.2
ARCH=shadowfax-westmere

#/apps/easybuild/software/shadowfax-westmere/EasyBuild/3.0.0/lib64/python2.6/site-packages/easybuild_easyblocks-3.0.0-py2.6.egg/easybuild/easyblocks/

patch -p 0 /apps/easybuild/software/${ARCH}/EasyBuild/${VER}/lib64/python2.6/site-packages/easybuild_easyblocks-${VER}-py2.6.egg/easybuild/easyblocks/e/easybuildmeta.py <  /apps/easybuild/patches/easybuildmeta.diff
