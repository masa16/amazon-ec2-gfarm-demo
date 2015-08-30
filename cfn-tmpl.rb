KEY_NAME, SUBNET_CIDR, MDS_IP, CN_IP, n =
`source ./env.sh; echo $keyname $subnet_cidr $mds_ip $cn_ip $n_fsn`.chomp.split
N_FSN = n.to_i

CloudFormation do
  Description("AWS CloudFormation Sample Template")
  AWSTemplateFormatVersion("2010-09-09")

  Dir.glob('cfn/*.rb') do |f|
    binding.eval(File.open(f).read, f)
  end
end
