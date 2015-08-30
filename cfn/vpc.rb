  Parameter("SSHLocation") do
    Description(" The IP address range that can be used to SSH to the EC2 instances")
    Type("String")
    Default("0.0.0.0/0")
    AllowedPattern("(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})/(\\d{1,2})")
    MaxLength(18)
    MinLength(9)
    ConstraintDescription("must be a valid IP CIDR range of the form x.x.x.x/x.")
  end

  Resource("VPC") do
    Type("AWS::EC2::VPC")
    Property("CidrBlock", SUBNET_CIDR)
    Property("Tags", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      }
    ])
    Property("EnableDnsHostnames", true)
  end

  Resource("Subnet") do
    Type("AWS::EC2::Subnet")
    Property("VpcId", Ref("VPC"))
    Property("CidrBlock", SUBNET_CIDR)
    Property("Tags", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      }
    ])
  end

  Resource("InternetGateway") do
    Type("AWS::EC2::InternetGateway")
    Property("Tags", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      }
    ])
  end

  Resource("AttachGateway") do
    Type("AWS::EC2::VPCGatewayAttachment")
    Property("VpcId", Ref("VPC"))
    Property("InternetGatewayId", Ref("InternetGateway"))
  end

  Resource("RouteTable") do
    Type("AWS::EC2::RouteTable")
    Property("VpcId", Ref("VPC"))
    Property("Tags", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      }
    ])
  end

  Resource("Route") do
    Type("AWS::EC2::Route")
    DependsOn("AttachGateway")
    Property("RouteTableId", Ref("RouteTable"))
    Property("DestinationCidrBlock", "0.0.0.0/0")
    Property("GatewayId", Ref("InternetGateway"))
  end

  Resource("SubnetRouteTableAssociation") do
    Type("AWS::EC2::SubnetRouteTableAssociation")
    Property("SubnetId", Ref("Subnet"))
    Property("RouteTableId", Ref("RouteTable"))
  end

  Resource("NetworkAcl") do
    Type("AWS::EC2::NetworkAcl")
    Property("VpcId", Ref("VPC"))
    Property("Tags", [
      {
        "Key"   => "Application",
        "Value" => Ref("AWS::StackId")
      }
    ])
  end

  Resource("InboundHTTPNetworkAclEntry") do
    Type("AWS::EC2::NetworkAclEntry")
    Property("NetworkAclId", Ref("NetworkAcl"))
    Property("RuleNumber", "100")
    Property("Protocol", "6")
    Property("RuleAction", "allow")
    Property("Egress", "false")
    Property("CidrBlock", "0.0.0.0/0")
    Property("PortRange", {
      "From" => "80",
      "To"   => "80"
    })
  end

  Resource("InboundSSHNetworkAclEntry") do
    Type("AWS::EC2::NetworkAclEntry")
    Property("NetworkAclId", Ref("NetworkAcl"))
    Property("RuleNumber", "101")
    Property("Protocol", "6")
    Property("RuleAction", "allow")
    Property("Egress", "false")
    Property("CidrBlock", "0.0.0.0/0")
    Property("PortRange", {
      "From" => "22",
      "To"   => "22"
    })
  end

  Resource("InboundResponsePortsNetworkAclEntry") do
    Type("AWS::EC2::NetworkAclEntry")
    Property("NetworkAclId", Ref("NetworkAcl"))
    Property("RuleNumber", "102")
    Property("Protocol", "6")
    Property("RuleAction", "allow")
    Property("Egress", "false")
    Property("CidrBlock", "0.0.0.0/0")
    Property("PortRange", {
      "From" => "1024",
      "To"   => "65535"
    })
  end

  Resource("OutBoundHTTPNetworkAclEntry") do
    Type("AWS::EC2::NetworkAclEntry")
    Property("NetworkAclId", Ref("NetworkAcl"))
    Property("RuleNumber", "100")
    Property("Protocol", "6")
    Property("RuleAction", "allow")
    Property("Egress", "true")
    Property("CidrBlock", "0.0.0.0/0")
    Property("PortRange", {
      "From" => "80",
      "To"   => "80"
    })
  end

  Resource("OutBoundHTTPSNetworkAclEntry") do
    Type("AWS::EC2::NetworkAclEntry")
    Property("NetworkAclId", Ref("NetworkAcl"))
    Property("RuleNumber", "101")
    Property("Protocol", "6")
    Property("RuleAction", "allow")
    Property("Egress", "true")
    Property("CidrBlock", "0.0.0.0/0")
    Property("PortRange", {
      "From" => "443",
      "To"   => "443"
    })
  end

  Resource("OutBoundResponsePortsNetworkAclEntry") do
    Type("AWS::EC2::NetworkAclEntry")
    Property("NetworkAclId", Ref("NetworkAcl"))
    Property("RuleNumber", "102")
    Property("Protocol", "6")
    Property("RuleAction", "allow")
    Property("Egress", "true")
    Property("CidrBlock", "0.0.0.0/0")
    Property("PortRange", {
      "From" => "1024",
      "To"   => "65535"
    })
  end

  Resource("SubnetNetworkAclAssociation") do
    Type("AWS::EC2::SubnetNetworkAclAssociation")
    Property("SubnetId", Ref("Subnet"))
    Property("NetworkAclId", Ref("NetworkAcl"))
  end

  Resource("MdsInstanceSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("VpcId", Ref("VPC"))
    Property("GroupDescription", "Gfarm Metadata Server")
    Property("SecurityGroupIngress", [
      {
        "CidrIp"     => Ref("SSHLocation"),
        "FromPort"   => "22",
        "IpProtocol" => "tcp",
        "ToPort"     => "22"
      },
      {
        "CidrIp"     => "0.0.0.0/0",
        "FromPort"   => "80",
        "IpProtocol" => "tcp",
        "ToPort"     => "80"
      },
      {
        "CidrIp"     => SUBNET_CIDR,
        "FromPort"   => "601",
        "IpProtocol" => "tcp",
        "ToPort"     => "601"
      },
      {
        "CidrIp"     => SUBNET_CIDR,
        "FromPort"   => "600",
        "IpProtocol" => "tcp",
        "ToPort"     => "600"
      },
      {
        "CidrIp"     => SUBNET_CIDR,
        "FromPort"   => "600",
        "IpProtocol" => "udp",
        "ToPort"     => "600"
      }
    ])
  end

  Resource("FsnInstanceSecurityGroup") do
    Type("AWS::EC2::SecurityGroup")
    Property("VpcId", Ref("VPC"))
    Property("GroupDescription", "Gfarm FileSystem Nodes")
    Property("SecurityGroupIngress", [
      {
        "CidrIp"     => SUBNET_CIDR,
        "FromPort"   => "22",
        "IpProtocol" => "tcp",
        "ToPort"     => "22"
      },
      {
        "CidrIp"     => SUBNET_CIDR,
        "FromPort"   => "600",
        "IpProtocol" => "tcp",
        "ToPort"     => "600"
      },
      {
        "CidrIp"     => SUBNET_CIDR,
        "FromPort"   => "600",
        "IpProtocol" => "udp",
        "ToPort"     => "600"
      }
    ])
  end
