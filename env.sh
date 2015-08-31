# AWS Region name
region=$(aws configure get region)
# InstanceType
instance_type=t2.micro

# KeyPair name
key_name=aws_gfarm
# SSH-key file
prikey_file=id_rsa-$key_name
pubkey_file=$prikey_file.pub

# IP address
subnet_cidr=10.0.0.0/24
mds_ip=10.0.0.10
cn_ip=10.0.0.11
# HostName alias
alias_mds=aws-mds
alias_cn=aws-cn

# MDS server DNS name
if [ -f MdsDnsName ]; then
  mds=$(cat MdsDnsName)
fi

# FSN hosts
if [ -f N_FSN ] ; then
  n_fsn=$(cat N_FSN)
  cn_hosts=$(ruby -e "x='ip-$cn_ip'.gsub(/\./,'-');$n_fsn.times{puts x;x=x.succ}")
fi
