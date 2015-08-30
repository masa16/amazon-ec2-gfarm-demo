# Specify image as:
# Property("ImageId", FnFindInMap("AWSRegionArch2AMI", Ref("AWS::Region"), FnFindInMap("AWSInstanceType2Arch", Ref("InstanceType"), "Arch")))

Parameter("InstanceType") do
  Description("Gfarm Cluster EC2 instance type")
  Type("String")
  Default("t2.micro")
  AllowedValues([
  "t1.micro",
  "t2.micro",
  "t2.small",
  "t2.medium",
  "m1.small",
  "m1.medium",
  "m1.large",
  "m1.xlarge",
  "m2.xlarge",
  "m2.2xlarge",
  "m2.4xlarge",
  "m3.medium",
  "m3.large",
  "m3.xlarge",
  "m3.2xlarge",
  "c1.medium",
  "c1.xlarge",
  "c3.large",
  "c3.xlarge",
  "c3.2xlarge",
  "c3.4xlarge",
  "c3.8xlarge",
  "c4.large",
  "c4.xlarge",
  "c4.2xlarge",
  "c4.4xlarge",
  "c4.8xlarge",
  "g2.2xlarge",
  "r3.large",
  "r3.xlarge",
  "r3.2xlarge",
  "r3.4xlarge",
  "r3.8xlarge",
  "i2.xlarge",
  "i2.2xlarge",
  "i2.4xlarge",
  "i2.8xlarge",
  "d2.xlarge",
  "d2.2xlarge",
  "d2.4xlarge",
  "d2.8xlarge",
  "hi1.4xlarge",
  "hs1.8xlarge",
  "cr1.8xlarge",
  "cc2.8xlarge",
  "cg1.4xlarge"
])
  ConstraintDescription("must be a valid EC2 instance type.")
end

Parameter("KeyName") do
  Description("Name of an existing EC2 KeyPair to enable SSH access to the instance")
  Type("AWS::EC2::KeyPair::KeyName")
  ConstraintDescription("must be the name of an existing EC2 KeyPair.")
end

Mapping("AWSInstanceType2Arch", {
  "c1.medium"   => {
    "Arch" => "PV64"
  },
  "c1.xlarge"   => {
    "Arch" => "PV64"
  },
  "c3.2xlarge"  => {
    "Arch" => "HVM64"
  },
  "c3.4xlarge"  => {
    "Arch" => "HVM64"
  },
  "c3.8xlarge"  => {
    "Arch" => "HVM64"
  },
  "c3.large"    => {
    "Arch" => "HVM64"
  },
  "c3.xlarge"   => {
    "Arch" => "HVM64"
  },
  "c4.2xlarge"  => {
    "Arch" => "HVM64"
  },
  "c4.4xlarge"  => {
    "Arch" => "HVM64"
  },
  "c4.8xlarge"  => {
    "Arch" => "HVM64"
  },
  "c4.large"    => {
    "Arch" => "HVM64"
  },
  "c4.xlarge"   => {
    "Arch" => "HVM64"
  },
  "cc2.8xlarge" => {
    "Arch" => "HVM64"
  },
  "cr1.8xlarge" => {
    "Arch" => "HVM64"
  },
  "d2.2xlarge"  => {
    "Arch" => "HVM64"
  },
  "d2.4xlarge"  => {
    "Arch" => "HVM64"
  },
  "d2.8xlarge"  => {
    "Arch" => "HVM64"
  },
  "d2.xlarge"   => {
    "Arch" => "HVM64"
  },
  "g2.2xlarge"  => {
    "Arch" => "HVMG2"
  },
  "hi1.4xlarge" => {
    "Arch" => "HVM64"
  },
  "hs1.8xlarge" => {
    "Arch" => "HVM64"
  },
  "i2.2xlarge"  => {
    "Arch" => "HVM64"
  },
  "i2.4xlarge"  => {
    "Arch" => "HVM64"
  },
  "i2.8xlarge"  => {
    "Arch" => "HVM64"
  },
  "i2.xlarge"   => {
    "Arch" => "HVM64"
  },
  "m1.large"    => {
    "Arch" => "PV64"
  },
  "m1.medium"   => {
    "Arch" => "PV64"
  },
  "m1.small"    => {
    "Arch" => "PV64"
  },
  "m1.xlarge"   => {
    "Arch" => "PV64"
  },
  "m2.2xlarge"  => {
    "Arch" => "PV64"
  },
  "m2.4xlarge"  => {
    "Arch" => "PV64"
  },
  "m2.xlarge"   => {
    "Arch" => "PV64"
  },
  "m3.2xlarge"  => {
    "Arch" => "HVM64"
  },
  "m3.large"    => {
    "Arch" => "HVM64"
  },
  "m3.medium"   => {
    "Arch" => "HVM64"
  },
  "m3.xlarge"   => {
    "Arch" => "HVM64"
  },
  "r3.2xlarge"  => {
    "Arch" => "HVM64"
  },
  "r3.4xlarge"  => {
    "Arch" => "HVM64"
  },
  "r3.8xlarge"  => {
    "Arch" => "HVM64"
  },
  "r3.large"    => {
    "Arch" => "HVM64"
  },
  "r3.xlarge"   => {
    "Arch" => "HVM64"
  },
  "t1.micro"    => {
    "Arch" => "PV64"
  },
  "t2.medium"   => {
    "Arch" => "HVM64"
  },
  "t2.micro"    => {
    "Arch" => "HVM64"
  },
  "t2.small"    => {
    "Arch" => "HVM64"
  }
})

Mapping("AWSRegionArch2AMI", {
  "ap-northeast-1" => {
    "HVM64" => "ami-cbf90ecb",
    "HVMG2" => "ami-6318e863",
    "PV64"  => "ami-27f90e27"
  },
  "ap-southeast-1" => {
    "HVM64" => "ami-68d8e93a",
    "HVMG2" => "ami-3807376a",
    "PV64"  => "ami-acd9e8fe"
  },
  "ap-southeast-2" => {
    "HVM64" => "ami-fd9cecc7",
    "HVMG2" => "ami-89790ab3",
    "PV64"  => "ami-ff9cecc5"
  },
  "cn-north-1"     => {
    "HVM64" => "ami-f239abcb",
    "HVMG2" => "NOT_SUPPORTED",
    "PV64"  => "ami-fa39abc3"
  },
  "eu-central-1"   => {
    "HVM64" => "ami-a8221fb5",
    "HVMG2" => "ami-7cd2ef61",
    "PV64"  => "ami-ac221fb1"
  },
  "eu-west-1"      => {
    "HVM64" => "ami-a10897d6",
    "HVMG2" => "ami-d5bc24a2",
    "PV64"  => "ami-bf0897c8"
  },
  "sa-east-1"      => {
    "HVM64" => "ami-b52890a8",
    "HVMG2" => "NOT_SUPPORTED",
    "PV64"  => "ami-bb2890a6"
  },
  "us-east-1"      => {
    "HVM64" => "ami-1ecae776",
    "HVMG2" => "ami-8c6b40e4",
    "PV64"  => "ami-1ccae774"
  },
  "us-west-1"      => {
    "HVM64" => "ami-d114f295",
    "HVMG2" => "ami-f31ffeb7",
    "PV64"  => "ami-d514f291"
  },
  "us-west-2"      => {
    "HVM64" => "ami-e7527ed7",
    "HVMG2" => "ami-abbe919b",
    "PV64"  => "ami-ff527ecf"
  }
})
