source ./env.sh

mds_host=ip-$(echo $mds_ip|sed 's/\./-/g')

s="
echo '> make gfarm-config.tar on MDS'
sudo tar cf - /etc/gfarm2.conf /home/_gfarmfs/.gfarm_shared_key /home/ec2-user/.gfarm_shared_key /var/www/.gfarm_shared_key > /tmp/gfarm-config.tar
list='
$cn_hosts
'
for i in \$list; do
  echo '> setup gfsd on '\$i
  scp /tmp/gfarm-config.tar \$i:/tmp
  ssh -t \$i '
    set -v
    sudo tar xpf /tmp/gfarm-config.tar -C /
    rm /tmp/gfarm-config.tar
    arch=x86_64-amsn-linux
    h=\$(hostname -f)
    gfhost -c -a \$arch -p 600 -n 1 \$h
    sudo config-gfsd -a \$arch -h \$h
    sudo chkconfig --add gfsd
    #sudo service gfsd start
    sudo /usr/sbin/gfsd -P /var/run/gfsd.pid -f /etc/gfarm2.conf -h \$h -r /var/gfarm-spool
    ps auxw|grep sbin/gfsd|grep -v grep'
done
echo '> remove gfarm-config.tar on MDS'
rm /tmp/gfarm-config.tar
"
echo "$s"
ssh -t $mds "$s"
