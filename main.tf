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

//Create the DMZ Subnet
resource "aws_subnet" "DmzSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.0.0/23"
  tags = {
    Name                  ="DmzSubnet1a--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

resource "aws_subnet" "DmzSubnet1b" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.2.0/23"
  tags = {
    Name                  ="DmzSubnet1b--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

resource "aws_subnet" "PublicSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.4.0/23"
  tags = {
    Name                  ="PublicSubnet1a--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

resource "aws_subnet" "PublicSubnet1b" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.6.0/23"
  tags = {
    Name                  ="PublicSubnet1b--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

resource "aws_subnet" "PrivateSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.8.0/23"
  tags = {
    Name                  ="PrivateSubnet1a--TF"
    Environment           = "${var.EnvironmntName}"
  }
}

resource "aws_subnet" "PrivateSubnet1b" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.10.0/23"
  tags = {
    Name                  ="PrivateSubnet1b--TF"
    Environment           = "QA"
  }
}

resource "aws_route_table" "mainRouteTable" {
  vpc_id                  = "${aws_vpc.main.id}"
  tags = {
    Name                  ="MainRouteTable--TF"
    Environment           = "QA"
  }
}


