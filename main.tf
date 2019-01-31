// https://www.itdiversified.com/comparing-toolsets-for-automating-cloud-infrastructure/

// Set the provider
provider "aws" {
  region = "us-east-1"
  profile = "terraform-user"
}

//Create the VPC
resource "aws_vpc" "main" {
  cidr_block                = "192.168.0.0/19"
  enable_dns_support        = true
  enable_dns_hostnames      = false
  instance_tenancy          = "default"
  tags = {
    Name                    = "VPC--TF"
    Environment             = "var.EnvironmntName"
  }
}

//Create the DMZ Subnet1a
resource "aws_subnet" "DmzSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.0.0/23"
  tags = {
    Name                  ="DmzSubnet1a--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the DMZ Subnet1b
resource "aws_subnet" "DmzSubnet1b" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.2.0/23"
  tags = {
    Name                  ="DmzSubnet1b--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the Public Subnet1a
resource "aws_subnet" "PublicSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.4.0/23"
  tags = {
    Name                  ="PublicSubnet1a--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the Public Subnet1b
resource "aws_subnet" "PublicSubnet1b" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.6.0/23"
  tags = {
    Name                  ="PublicSubnet1b--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the Private Subnet1a
resource "aws_subnet" "PrivateSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.8.0/23"
  tags = {
    Name                  ="PrivateSubnet1a--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the Private Subnet1b
resource "aws_subnet" "PrivateSubnet1b" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.10.0/23"
  tags = {
    Name                  ="PrivateSubnet1b--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the main route table
resource "aws_route_table" "mainRouteTable" {
  vpc_id                  = "${aws_vpc.main.id}"
  tags = {
    Name                  = "MainRouteTable--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the internet gateway
resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name                  ="InternetGateway--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the public route
resource "aws_route" "PublicRoute" {
  route_table_id = "${aws_route_table.mainRouteTable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.InternetGateway.id}"
}

//Create the DMZ route table
resource "aws_route_table" "DmzRouteTable" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name                  ="DmzRouteTable--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the DMZ public route
resource "aws_route" "DmzPublicRoute" {
  route_table_id = "${aws_route_table.DmzRouteTable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.InternetGateway.id}"
}

//Associate the DMZ Subnets to the DMZ route table  AWS::EC2::SubnetRouteTableAssociation
resource "aws_route_table_association" "DmzRouteAssociation1a" {
  route_table_id = "${aws_route_table.DmzRouteTable.id}"
  subnet_id = "${aws_subnet.DmzSubnet1b.id}"
}
resource "aws_route_table_association" "DmzRouteAssociation1b" {
  route_table_id = "${aws_route_table.DmzRouteTable.id}"
  subnet_id = "${aws_subnet.DmzSubnet1b.id}"
}

//Create the public route table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = "${aws_vpc.main.id}"
  tags = {
    Name                  ="PublicRouteTable--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the public route
resource "aws_route" "PublicPublicRoute" {
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.InternetGateway.id}"
}

//Associate the Public Subnets to the public route table - AWS::EC2::SubnetRouteTableAssociation
resource "aws_route_table_association" "PublicRouteAssociation1a" {
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
  subnet_id = "${aws_subnet.PublicSubnet1a.id}"
}
resource "aws_route_table_association" "PublicRouteAssociation1b" {
  route_table_id = "${aws_route_table.PublicRouteTable.id}"
  subnet_id = "${aws_subnet.PublicSubnet1b.id}"
}

// Create the elastic IP for NAT 1
resource "aws_eip" "NatGateway1EIP" {
  depends_on = ["aws_internet_gateway.InternetGateway"]
  vpc = true
}

// Create the elastic IP for NAT 2
resource "aws_eip" "NatGateway2EIP" {
  depends_on = ["aws_internet_gateway.InternetGateway"]
  vpc = true
}

// Create the gateway for NAT 1
resource "aws_nat_gateway" "NatGatewayAZ1" {
  allocation_id = "${aws_eip.NatGateway1EIP.id}"
  subnet_id = "${aws_subnet.PublicSubnet1a.id}"
  tags = {
    Name                  ="NatGatewayAZ1--TF"
    Environment           = "${var.EnvironmntName}"
  }
}
// Create the gateway for NAT 2
resource "aws_nat_gateway" "NatGatewayAZ2" {
  allocation_id = "${aws_eip.NatGateway2EIP.id}"
  subnet_id = "${aws_subnet.PublicSubnet1b.id}"
  tags = {
    Name                  ="NatGatewayAZ2--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the private route table for availability zone 1
resource "aws_route_table" "PrivateRouteTableAZ1" {
  vpc_id = "${aws_vpc.main.id}"
    tags = {
    Name                  ="PrivateRouteTableAZ1--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the private route for availability zone 2
resource  "aws_route" "PrivateNatRoute1" {
  route_table_id = "${aws_route_table.PrivateRouteTableAZ1.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.NatGatewayAZ1.id}"
}

//Create the private route association for availability zone 1
resource "aws_route_table_association" "PrivateSubnet1aRouteTbleAsociation" {
  route_table_id = "${aws_route_table.PrivateRouteTableAZ1.id}"
  subnet_id = "${aws_subnet.PrivateSubnet1a.id}"
}

//Create the private route table for availability zone 1
resource "aws_route_table" "PrivateRouteTableAZ2" {
  vpc_id = "${aws_vpc.main.id}"
    tags = {
    Name                  ="PrivateRouteTableAZ2--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

//Create the private route for availability zone 2
resource  "aws_route" "PrivateNatRoute2" {
  route_table_id = "${aws_route_table.PrivateRouteTableAZ2.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.NatGatewayAZ2.id}"
}

//Create the private route association for availability zone 1
resource "aws_route_table_association" "PrivateSubnet1bRouteTbleAsociation" {
  route_table_id = "${aws_route_table.PrivateRouteTableAZ2.id}"
  subnet_id = "${aws_subnet.PrivateSubnet1b.id}"
}

// Create IAM role and policy
resource "aws_iam_role" "Ec2Role" {
  name = "Ec2Role"
  path = "/"
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
         "Statement": [
          {
            "Effect": "Allow",
            "Principal": {
              "Service": [
                "ec2.amazonaws.com"
              ]
            },
            "Action": [
              "sts:AssumeRole"
            ]
          }
        ]
  }
  EOF
}

