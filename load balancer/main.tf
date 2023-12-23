provider "aws" {
    region = var.region
  
}
resource "aws_vpc" "sngpr-vpc" {
    cidr_block = "192.168.10.0/24"

    tags = {
      Name = "sngpr-vpc"

    }
  
}
resource "aws_subnet" "pub_sub" {
    vpc_id = aws_vpc.sngpr-vpc.id
    count = 2
    cidr_block = cidrsubnet(aws_vpc.sngpr-vpc.cidr_block,1,count.index)
    availability_zone = var.zones[count.index]

    tags = {
        Name = "pub-sub-${count.index+1}"
    }  
}
resource "aws_security_group" "ALB_sg" {
    vpc_id = aws_vpc.sngpr-vpc.id
    name = "ALB-sg"
  
}
resource "aws_security_group_rule" "inbound" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.ALB_sg.id

  
}
resource "aws_security_group_rule" "outbound" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.ALB_sg.id
  
}
resource "aws_internet_gateway" "sngpr_IGW" {
    vpc_id = aws_vpc.sngpr-vpc.id

    tags = {
      Name = "sngpr-IGW"
    }
  
}
resource "aws_lb_target_group" "ALB_tg" {
    name = "singa-ALB-TG"
    port = 80
    protocol = "HTTP"
    vpc_id = aws_vpc.sngpr-vpc.id

    tags = {
      Name = "ALB-TG"
    }
  
}
resource "aws_lb" "sngpr_ALB" {
    name = "sngpr-ALB"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.ALB_sg.id]
    subnets = [for subnet in aws_subnet.pub_sub : subnet.id]

    tags = {
      Name = "SNGPR_ALB"

    }
}
resource "aws_lb_listener" "lb_listerner" {
    load_balancer_arn = aws_lb.sngpr_ALB.arn
    port = "443"
    protocol = "HTTP"
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.ALB_tg.arn
    }
  
}
resource "aws_instance" "sngpr_insta" {
    ami = "ami-0172cbe2088c3bb63"
    instance_type = "t2.micro"
    key_name = "jnks"
    count = 1
    availability_zone = var.insta[count.index]
    subnet_id = aws_subnet.pub_sub[count.index].id
    
    tags = {
      Name = "sngpr-insta-${count.index+1}"

    }
  
}

