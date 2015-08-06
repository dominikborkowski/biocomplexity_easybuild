# to run easybuild jobs via gc3pie and torque, we need to load appropriate modules

. /etc/profile.d/modules.sh

module load site/shadowfax/easybuild/setup
module load EasyBuild
module load GC3Pie
