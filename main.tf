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
  subnet_id = "${aws_subnet.DmzSubnet1a.id}"
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

//Create the private route for availability zone 1
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

//Create the private route table for availability zone 2
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

//Create the private route association for availability zone 2
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

// Create instance of profile for Ec2Role
resource "aws_iam_instance_profile" "Ec2RoleInstanceProfile" {
  path = "/"
  role = "${aws_iam_role.Ec2Role.name}"
}

// Create  a policy
resource "aws_iam_policy" "S3buildAccessPolicyTF" {
  name        = "S3buildAccessPolicyTF"
  path        = "/"
  description = "Allows s3 access"

  policy = <<EOF
{
  "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:*"
          ],
          "Resource": [
            "arn:aws:s3:::qa-storage--dashboard/*",
            "arn:aws:s3:::qa-storage--dashboard"
          ]
        }
      ]
}
EOF
}

//Attach the policy
resource "aws_iam_policy_attachment" "s3Attach" {
  name       = "s3Attach-TF"
  roles      = ["${aws_iam_role.Ec2Role.name}"]
  policy_arn = "${aws_iam_policy.S3buildAccessPolicyTF.arn}"
}


//Create  a load balancer security group - Allow all traffic to reach the load balancer - further rules will allow secure routing of traffic
resource "aws_security_group" "LoadBalancerSecGrp" {
  name        = "LoadBalancerSecGrp-TF"
  description = "Load balancer security group"
  vpc_id      = "${aws_vpc.main.id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//Create  a instance security group
resource "aws_security_group" "instanceSecGrp" {
  name        = "instanceSecGrp-TF"
  description = "Enable SSH access via port 22"
  vpc_id      = "${aws_vpc.main.id}"
  //depends_on = ["${aws_security_group.loadbalancer}"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["74.94.81.157/32"]
  }
}

// HTTP Traffic only into instances from the load balancer
resource "aws_security_group_rule" "HttpFromLoadBalancerRule" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.instanceSecGrp.id}"
  source_security_group_id = "${aws_security_group.LoadBalancerSecGrp.id}"
  //cidr_blocks = []
}

// HTTP Traffic only from instances to the load balancer
resource "aws_security_group_rule" "HttpFromInstanceRule" {
  type = "egress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  security_group_id = "${aws_security_group.LoadBalancerSecGrp.id}"
  source_security_group_id = "${aws_security_group.instanceSecGrp.id}"
  //cidr_blocks = []
}

// Create the Application Load Balancer
resource "aws_lb" "productionApplication-AplicationLoadBalancer" {
  name                      = "Production-ALB--TF"
  internal                  = false
  load_balancer_type        = "application"
  security_groups           = ["${aws_security_group.LoadBalancerSecGrp.id}"]
  subnets                   =  ["${aws_subnet.DmzSubnet1a.id}", "${aws_subnet.DmzSubnet1b.id}"]
  //subnets                   = "${var.DMZSubnetIds}"
  enable_deletion_protection = false

//  access_logs {
//    bucket = "${var.MyBucket}"
//    prefix = "logs"
//    enabled = true
//  }
  tags = {
    Name                    = "Elastic Load Balancer - TF"
    Environment             = "var.EnvironmntName"
  }

}

// Create the load balancer target group
resource "aws_lb_target_group" "APP-TargGrp--TF" {
  name                      = "APP-TargGrp--TF"
  port                      = 80
  protocol                  = "HTTP"
  vpc_id                    = "${aws_vpc.main.id}"

  health_check {
    interval                = "30"
    path                    = "/"
    protocol                = "HTTP"
    healthy_threshold       = "2"
    unhealthy_threshold     = "5"
    timeout                 = "28"
    matcher                 = "200"
  }
}

// Create the load balancer listener
resource "aws_lb_listener" "APP-HTTP-Listener--TF" {
  load_balancer_arn         = "${aws_lb.productionApplication-AplicationLoadBalancer.arn}"
  port                      = "80"
  protocol                  = "HTTP"

  default_action {
    type                    = "forward"
    target_group_arn        = "${aws_lb_target_group.APP-TargGrp--TF.arn}"
  }
}

// Create the launch configuration for the load balancer
resource "aws_launch_configuration" "App_LC--TF" {
  name                      = "QA-App_LC--TF"
  image_id                  = "${var.amiId}"
  instance_type             = "t2.micro"
  iam_instance_profile      = "QA-EC2-Role--Dashboard"
  key_name                  = "udemy-ec2"
  ebs_optimized             = "false"
  enable_monitoring         = "false"
  security_groups           = ["sg-0b873c7f2a3b27a69"]
  user_data                 = "${file("${var.userDataPath}")}"

}

/*
// Create the autoscaling group
resource "aws_autoscaling_group" "QA-Prod-autoscale-grp" {
  availability_zones = ["us-east-1a", "us-east-1b"]
  name                      = "QA-Prod-autoscale-grp--TF"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  launch_configuration      = "${aws_launch_configuration.App_LC--TF.name}"
  target_group_arns         = ["${aws_lb_target_group.APP-TargGrp--TF.arn}"]
  termination_policies      = ["OldestInstance"]
  vpc_zone_identifier       = "${var.PublicSubnetIDs}"
  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
    tag {
    key = "Name"
    value = "QA_ASG--TF"
      propagate_at_launch = true
  }
}





// Create the notification
resource "aws_autoscaling_notification" "asg_activity_notification" {
  group_names = [
    "${aws_autoscaling_group.QA-Prod-autoscale-grp.name}"
  ]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  topic_arn = "${var.autoscaling_notification_arn}"
}

// Create the High CPU alarm
resource "aws_cloudwatch_metric_alarm" "High_Cpu_Alarm" {
  alarm_name = "App_High_Cpu_Alarm--TF"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "5"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "60"
  statistic = "Average"
  threshold = "80"
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions          = ["${aws_autoscaling_policy.app_scaleup_policy.arn}"]
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.QA-Prod-autoscale-grp.name}"
  }
}

// Create the autoscaling up policy
resource "aws_autoscaling_policy" "app_scaleup_policy" {
  name                   = "app_scaleup_policy--TF"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.QA-Prod-autoscale-grp.name}"
}

// Create the Low CPU alarm
resource "aws_cloudwatch_metric_alarm" "Low_Cpu_Alarm" {
  alarm_name            = "App_Low_Cpu_Alarm--TF"
  comparison_operator   = "LessThanOrEqualToThreshold"
  evaluation_periods    = "5"
  metric_name           = "CPUUtilization"
  namespace             = "AWS/EC2"
  period                = "60"
  statistic             = "Average"
  threshold             = "30"
  alarm_description     = "This metric monitors ec2 cpu utilization"
  alarm_actions         = ["${aws_autoscaling_policy.app_scaledown_policy.arn}"]
  dimensions            = {
      AutoScalingGroupName = "${aws_autoscaling_group.QA-Prod-autoscale-grp.name}"
  }
}

// Create the autoscaling down policy
resource "aws_autoscaling_policy" "app_scaledown_policy" {
  name                   = "app_scaledown_policy--TF"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.QA-Prod-autoscale-grp.name}"
}
*/
