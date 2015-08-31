source ./env.sh

rcmd='
d=gfm
mkdir -p $d
gfarm2fs $d
cd $d
wget -nv https://s3-us-west-2.amazonaws.com/masa16/pwrake/montage-m31.tar -O - | tar xf -
cd montage-m31
cat <<EOF > hosts
'$cn_hosts'
EOF
'

echo "$rcmd"
ssh "$mds" "$rcmd"
