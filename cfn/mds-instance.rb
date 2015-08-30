PKG_LIST=%w[rpm-build gcc openssl-devel postgresql94-devel postgresql94-server fuse fuse-devel libacl-devel ruby-devel gnuplot]
YUM_PKGS={}
PKG_LIST.each{|x| YUM_PKGS[x]=[]}

Resource("MdsInstance") do
  Type("AWS::EC2::Instance")
  Property("ImageId", FnFindInMap("AWSRegionArch2AMI", Ref("AWS::Region"), FnFindInMap("AWSInstanceType2Arch", Ref("InstanceType"), "Arch")))
  Property("InstanceType", Ref("InstanceType"))
  Property("KeyName", Ref("KeyName"))
  Property("Tags", [
    {
      "Key"   => "ServerType",
      "Value" => "MDS"
    },
    {
      "Key"   => "Application",
      "Value" => Ref("AWS::StackId")
    }
  ])
  Property("NetworkInterfaces", [
    {
      "AssociatePublicIpAddress" => true,
      "DeviceIndex"              => 0,
      "GroupSet"                 => [Ref("MdsInstanceSecurityGroup")],
      "PrivateIpAddress"         => MDS_IP,
      "SubnetId"                 => Ref("Subnet")
    }
  ])

  Property("UserData", FnBase64(FnJoin("",["#!/bin/bash
yum update -y

# Helper function
function error_exit
{
  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '",Ref("MdsWaitHandle"),"'
  exit 1
}

# Install packages
/opt/aws/bin/cfn-init -s ",Ref("AWS::StackId")," -r MdsInstance --region ",
Ref("AWS::Region")," || error_exit 'Failed to run cfn-init'

# Make user: _gfarmfs
groupadd -g 456 _gfarmfs
useradd -m -u 456 -g _gfarmfs -d /home/_gfarmfs _gfarmfs

# download
cd /tmp
u=https://s3-us-west-2.amazonaws.com/masa16/amzn-linux
rpms='
gfarm-client-2.6.6-1.amzn1.x86_64.rpm
gfarm-devel-2.6.6-1.amzn1.x86_64.rpm
gfarm-doc-2.6.6-1.amzn1.x86_64.rpm
gfarm-fsnode-2.6.6-1.amzn1.x86_64.rpm
gfarm-libs-2.6.6-1.amzn1.x86_64.rpm
gfarm-server-2.6.6-1.amzn1.x86_64.rpm
gfarm2fs-1.2.9.8-1.amzn1.x86_64.rpm
'
for i in $rpms; do wget -nv $u$i; done

# install libs
rpm -iv gfarm-libs-*.rpm
# install mds, fsn, client
rpm -iv gfarm-client-*.rpm gfarm-server-*.rpm gfarm-fsnode-*.rpm gfarm-doc-*.rpm
# install gfarm2fs
rpm -iv --force gfarm2fs-*.rpm

# config gfmd
config-gfarm -A ec2-user
su _gfarmfs sh -c 'cd; gfkey -f -p 94608000'
su ec2-user sh -c 'cd; gfkey -f -p 94608000'

# config gfsd
arch=x86_64-amsn-linux
su ec2-user -c 'gfhost -c -a '$arch' -p 600 -n 1 '$(hostname -f)
config-gfsd -a $arch -h $(hostname -f)
chkconfig --add gfsd
service gfsd start

# isntall gems
gem install rake ffi

# install pwrake
wget -nv https://github.com/masa16/pwrake2/archive/master.tar.gz -O pwrake2.tar.gz
tar xzf pwrake2.tar.gz
cd pwrake2-master
ruby setup.rb
cd ..

# install Montage
wget -nv https://s3-us-west-2.amazonaws.com/masa16/amzn-linux/Montage_v3.3-bin-amzn.tar.gz
tar xzf Montage_v3.3-bin-amzn.tar.gz -C /usr/local

# All is well so signal success
/opt/aws/bin/cfn-signal -e 0 -r 'GfarmMDS setup complete' '",Ref("MdsWaitHandle"),"'
"])))

  Metadata("Comment", "Install Gfarm MDS")
  Metadata("AWS::CloudFormation::Init", {
    "config" => {
      "files"    => {
        "/etc/cfn/hooks.d/cfn-auto-reloader.conf" => {
          "content" => FnJoin("", [
            "[cfn-auto-reloader-hook]\n",
            "triggers=post.update\n",
            "path=Resources.MdsInstance.Metadata.AWS::CloudFormation::Init\n",
            "action=/opt/aws/bin/cfn-init -s ", Ref("AWS::StackId"),
            " -r MdsInstance ", " --region ", Ref("AWS::Region"), "\n",
            "runas=root\n" ])
        }
      },
      "packages" => {
        "yum" => YUM_PKGS
      }
      #"services" => {
      #  "sysvinit" => {
      #    "httpd"    => {
      #      "enabled"       => "true",
      #      "ensureRunning" => "true"
      #    },
      #  }
      #}
    }
  })

end

Resource("MdsWaitHandle") do
  Type("AWS::CloudFormation::WaitConditionHandle")
end

Output("MdsInstanceId") do
  Description("InstanceId of the EC2 MDS instance")
  Value(Ref("MdsInstance"))
end

Output("MdsAZ") do
  Description("Availability Zone of the EC2 MDS instance")
  Value(FnGetAtt("MdsInstance", "AvailabilityZone"))
end

Output("MdsPublicDNS") do
  Description("Public DNSName of the EC2 MDS instance")
  Value(FnGetAtt("MdsInstance", "PublicDnsName"))
end

Output("MdsPublicIP") do
  Description("Public IP address of the EC2 MDS instance")
  Value(FnGetAtt("MdsInstance", "PublicIp"))
end
