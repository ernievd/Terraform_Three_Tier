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
    Environment             = "QA"
  }
}

//Create the DMZ Subnet
resource "aws_subnet" "DmzSubnet1a" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "192.168.0.0/23"
  tags = {
    Name                  ="DmzSubnet1a--TF"
    Environment           = "QA"
  }
}

