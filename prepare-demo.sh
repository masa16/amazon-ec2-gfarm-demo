source ./env.sh

rcmd='
mkdir gfm
gfarm2fs gfm
cd gfm
wget -nv https://s3-us-west-2.amazonaws.com/masa16/pwrake/montage-m31.tar -O - | tar xf -
cd montage-m31
cat <<EOF > hosts
'$cn_hosts'
EOF
'

echo "$rcmd"
ssh "$mds" "$rcmd"
