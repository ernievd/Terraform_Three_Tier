
variable "region" {
  description      = "The AWS region."
  default          = "us-east-1"
}

variable "EnvironmntName" {
  description     = "The AWS region."
  default         = "QA"
}

variable "amiId" {
  default = "ami-035be7bafff33b6b6"
}

variable "userDataPath" {
  default = "//home//ernie//TerraformProject1//userdata.txt"
}