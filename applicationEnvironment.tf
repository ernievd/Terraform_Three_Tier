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
    Environment             = "QA"
    Name                    = "QA-VPC--TF"
  }
}

