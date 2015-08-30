region=$(aws configure get region)
keyname=aws_gfarm
prikey_file=id_rsa-$keyname
pubkey_file=$prikey_file.pub

subnet_cidr=10.0.0.0/24
mds_ip=10.0.0.10
cn_ip=10.0.0.11
alias_mds=aws-mds
alias_cn=aws-cn
if [ -f MdsDnsName ]; then
  mds=$(cat MdsDnsName)
fi
if [ -f N_FSN ] ; then
  n_fsn=$(cat N_FSN)
  cn_hosts=$(ruby -e "x='ip-$cn_ip'.gsub(/\./,'-');$n_fsn.times{puts x;x=x.succ}")
fi
