# run by root
gfarm_version=2.6.9
gfarm2fs_version=1.2.9.9
d=~/rpmbuild/RPMS/x86_64

# install mds
rpm -ihv --nodeps --force $d/gfarm-server-$gfarm_version-*.rpm $d/gfarm-doc-$gfarm_version-*.rpm
# install fsd
rpm -ihv --nodeps --force $d/gfarm-fsnode-$gfarm_version-*.rpm
# install client
rpm -ihv --nodeps --force $d/gfarm-client-$gfarm_version-*.rpm; $d/gfarm2fs-$gfarm2fs_version-*.rpm

# config gfmd
rm /etc/gfarm2.conf
rm /etc/gfmd.conf
rm -r /var/gfarm-pgsql
rm /etc/init.d/gfarm-pgsql

config-gfarm -A ec2-user
su _gfarmfs sh -c 'cd; gfkey -f -p 94608000'
su ec2-user sh -c 'cd; gfkey -f -p 94608000'

arch=x86_64-amsn-linux
su ec2-user gfhost -c -a $arch -p 600 -n 1 $(hostname -f)

# config gfsd
config-gfsd -a $arch
chkconfig --add gfmd
chkconfig --add gfarm-pgsql
chkconfig --add gfsd
