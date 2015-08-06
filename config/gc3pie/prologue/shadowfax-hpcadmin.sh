# to run easybuild jobs via gc3pie and torque, we need to load appropriate modules

. /etc/profile.d/modules.sh

module load site/shadowfax/easybuild/hpcadmin
module load EasyBuild
module load GC3Pie

# set the right umask for hpcadmin group - we want files to be writeable by group
umask 002

