provider "aws" {
    region = "ap-south-1"
  
}
resource "aws_vpc" "cust_vpc" {
    cidr_block = "10.0.0.0/24"

    tags = {
      Name="testing_vpc"

      env ="testing"
    }
  
}
resource "aws_subnet" "pub_sub" {
    vpc_id = aws_vpc.cust_vpc.id
    availability_zone = "ap-south-1a"
    cidr_block = "10.0.0.0/25"

    tags = {
      Name="public subnet"
    }
  
}
resource "aws_subnet" "pri_sub" {
    vpc_id = aws_vpc.cust_vpc.id
    availability_zone = "ap-south-1a"
    cidr_block = "10.0.0.128/25"

    tags = {
      Name="private subnet"

    }
  
}
resource "aws_internet_gateway" "IGW" {
    vpc_id = aws_vpc.cust_vpc.id

    tags = {
      Name="cust IGW"
    }
  
}
resource "aws_route_table" "pub-rt" {
    vpc_id = aws_vpc.cust_vpc.id
    route {
        cidr_block= "0.0.0.0/0"
        gateway_id= aws_internet_gateway.IGW.id
}
tags = {
    Name="pub rt"

}
  
}
resource "aws_route_table" "pri-rt" {
    vpc_id = aws_vpc.cust_vpc.id

   
    tags = {
        Name="pri rt"
    }
  
}

resource "aws_route_table_association" "pub-rt1" {
    subnet_id = aws_subnet.pub_sub.id
    route_table_id = aws_route_table.pub-rt.id

  
}
resource "aws_route_table_association" "pri-rt1" {
    subnet_id = aws_subnet.pri_sub.id
    route_table_id = aws_route_table.pri-rt.id
  
}