#!/bin/bash
yum update -y
yum install -y #{PKG_LIST.join(" ")}

gfarm_version=2.6.9
gfarm2fs_version=1.2.9.9

# download
wget http://sourceforge.net/projects/gfarm/files/gfarm_v2/$gfarm_version/gfarm-$gfarm_version-1.src.rpm
wget http://sourceforge.net/projects/gfarm/files/gfarm2fs/$gfarm2fs_version/gfarm2fs-$gfarm2fs_version-1.src.rpm

# extract spec
rpm -ivh gfarm-$gfarm_version-1.src.rpm

# modify postgresql-devel to postgresql94-devel
# add Provides: libgfarm.so.1 libgfperf.so.1
cd ~/rpmbuild/SPECS
mv gfarm.spec gfarm.spec.bak
sed s/postgresql-devel/postgresql94-devel/ gfarm.spec.bak \
| sed '/# always provide "gfarm-libs"/i\Provides: libgfarm.so.1()(64bit)\
Provides: libgfperf.so.1()(64bit)' > gfarm.spec

# build
rpmbuild -bb gfarm.spec

# uninstall
l='
gfarm-fsnode
gfarm-doc
gfarm-libs
gfarm-server
gfarm-client
gfarm2fs
'
sudo rpm -e $l

# install
d=~/rpmbuild/RPMS/x86_64
sudo rpm -ihv $d/gfarm-libs-*.rpm $d/gfarm-devel-*.rpm

# build gfarm2fs
rpmbuild --rebuild gfarm2fs-$gfarm2fs_version-1.src.rpm

# install all
cd $d
#gfarm-devel-*.rpm
#gfarm-libs-*.rpm
sudo rpm -ivh gfarm-client-*.rpm
sudo rpm -ivh gfarm2fs-*.rpm
sudo rpm -ivh gfarm-server-*.rpm
sudo rpm -ivh gfarm-fsnode-*.rpm
sudo rpm -ivh gfarm-doc-*.rpm
sudo rpm -ivh gfarm-ganglia-*.rpm

# copy to S3
for i in gfarm*.rpm; do
  aws s3 cp $i s3://masa16/amzn-linux/$i
done
