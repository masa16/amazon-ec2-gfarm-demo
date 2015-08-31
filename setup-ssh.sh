rm -f MdsDnsName
mds=`aws ec2 describe-instances --filter 'Name=tag:aws:cloudformation:logical-id,Values=MdsInstance' --query 'Reservations[].Instances[].[PublicDnsName]' --output text`
echo $mds > MdsDnsName
echo MdsDnsName=`cat MdsDnsName`

source ./env.sh

echo "> delete ec2 hosts from known_hosts"
mv $HOME/.ssh/known_hosts $HOME/.ssh/known_hosts.bak
sed '
/^[.a-z0-9-]*\.compute\.amazonaws\.com/d
/^ip-[0-9-]* /d
' $HOME/.ssh/known_hosts.bak > $HOME/.ssh/known_hosts

echo "> modify .ssh/config"
mv $HOME/.ssh/config $HOME/.ssh/config.bak
sed '/amazon ec2 begin/,/amazon ec2 end/d' $HOME/.ssh/config.bak > $HOME/.ssh/config

cnt="### amazon ec2 begin
Host $alias_mds $alias_cn* *.amazonaws.com
User ec2-user
IdentityFile ~/.ssh/$prikey_file
IdentitiesOnly yes
ForwardAgent yes
GSSAPIAuthentication no
StrictHostKeyChecking no

Host $alias_mds
HostName $mds

Host $alias_cn*
ProxyCommand ssh -q -W %h:%p $mds"

for i in $cn_hosts; do
 cnt="$cnt

Host $alias_cn"$(echo $i|ruby -e 'ARGF.read=~/(\d+)$/; puts $1')"
HostName $i"
done

cnt="$cnt
### amazon ec2 end"

echo "$cnt"
echo "$cnt" >> $HOME/.ssh/config
chmod 600 $HOME/.ssh/config

echo "> copy .ssh/$pubkey_file to aws-mds"
scp $HOME/.ssh/$pubkey_file $mds:.ssh/

rcmd="
echo '> create .ssh/config on aws-mds'
cat > ~/.ssh/config <<EOL
Host *
StrictHostKeyChecking no
Host ip-*
User ec2-user
IdentityFile ~/.ssh/$pubkey_file
IdentitiesOnly yes
ForwardAgent yes
GSSAPIAuthentication no
EOL
chmod 600 ~/.ssh/config ~/.ssh/$pubkey_file

echo '> copy SSH settings to $alias_cn*'
cd .ssh
list='
$cn_hosts
'
for i in \$list; do
  echo \"> copy .ssh/config .ssh/$pubkey_file to \$i\"
  scp config $pubkey_file \$i:.ssh/
done
"
echo "$rcmd"
ssh $mds "$rcmd"
