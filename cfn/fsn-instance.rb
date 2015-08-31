FSN_PKG_LIST=%w[fuse fuse-libs libgomp postgresql94-libs httpd]
FSN_YUM_PKGS={}
FSN_PKG_LIST.each{|x| FSN_YUM_PKGS[x]=[]}
cn_ip = CN_IP

(1..N_FSN).each do |index|

  instanceName = "Fsn#{index}Instance"
  waitHandle = "Fsn#{index}WaitHandle"

  Resource(instanceName) do
    Type("AWS::EC2::Instance")
    Property("ImageId", FnFindInMap("AWSRegionArch2AMI", Ref("AWS::Region"), FnFindInMap("AWSInstanceType2Arch", Ref("InstanceType"), "Arch")))
    Property("InstanceType", Ref("InstanceType"))
    Property("KeyName", Ref("KeyName"))
    Property("Tags", [
      {
        "Key"   => "ServerType",
        "Value" => "FSN"
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
        "GroupSet"                 => [Ref("FsnInstanceSecurityGroup")],
        "PrivateIpAddress"         => cn_ip,
        "SubnetId"                 => Ref("Subnet")
      }
    ])
    cn_ip = cn_ip.succ

    Property("UserData", FnBase64(FnJoin("",["#!/bin/bash
yum update -y

# Helper function
function error_exit
{
  /opt/aws/bin/cfn-signal -e 1 -r \"$1\" '",Ref(waitHandle),"'
  exit 1
}

# Install packages
/opt/aws/bin/cfn-init -s ",Ref("AWS::StackId")," -r #{instanceName} --region ",
Ref("AWS::Region")," || error_exit 'Failed to run cfn-init'

# Make user: _gfarmfs
groupadd -g 456 _gfarmfs
useradd -m -u 456 -g _gfarmfs -d /home/_gfarmfs _gfarmfs

# download
cd /tmp
u=https://s3-us-west-2.amazonaws.com/masa16/amzn-linux
rpms='
gfarm-client-2.6.6-1.amzn1.x86_64.rpm
gfarm-fsnode-2.6.6-1.amzn1.x86_64.rpm
gfarm-libs-2.6.6-1.amzn1.x86_64.rpm
gfarm-server-2.6.6-1.amzn1.x86_64.rpm
gfarm2fs-1.2.9.8-1.amzn1.x86_64.rpm
'
for i in $rpms; do wget -nv $u/$i; done

# install libs
rpm -iv gfarm-libs-*.rpm
# install fsd and client
rpm -iv gfarm-client-*.rpm gfarm-server-*.rpm gfarm-fsnode-*.rpm
# install gfarm2fs
rpm -iv --force gfarm2fs-*.rpm

# install Montage
wget -nv https://s3-us-west-2.amazonaws.com/masa16/amzn-linux/Montage_v3.3-bin-amzn.tar.gz
tar xzf Montage_v3.3-bin-amzn.tar.gz -C /usr/local

# All is well so signal success
/opt/aws/bin/cfn-signal -e 0 -r 'GfarmFSN setup complete' '",Ref(waitHandle),"'
"])))

    Metadata("Comment", "Install Gfarm FSN")
    Metadata("AWS::CloudFormation::Init", {
      "config" => {
        "files"    => {
          "/etc/cfn/hooks.d/cfn-auto-reloader.conf" => {
            "content" => FnJoin("", [
              "[cfn-auto-reloader-hook]\n",
              "triggers=post.update\n",
              "path=Resources.#{instanceName}.Metadata.AWS::CloudFormation::Init\n",
              "action=/opt/aws/bin/cfn-init -s ", Ref("AWS::StackId"),
              " -r #{instanceName} ", " --region ", Ref("AWS::Region"), "\n",
              "runas=root\n" ])
          }
        },
        "packages" => {
          "yum" => FSN_YUM_PKGS
        }
      }
    })

  end

  Resource(waitHandle) do
    Type("AWS::CloudFormation::WaitConditionHandle")
  end

  Output("Fsn#{index}InstanceId") do
    Description("InstanceId of the EC2 FSN#{index} instance")
    Value(Ref(instanceName))
  end
end
