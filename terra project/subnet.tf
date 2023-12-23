provider "aws" {
  region = "ap-south-1"
  
}
resource "aws_vpc" "new_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "new vpc"
  }
  
}
resource "aws_subnet" "pub-sub" {
  vpc_id = aws_vpc.new_vpc.id
  cidr_block = "10.0.10.0/23"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "pub-sub"
  }
  
}
resource "aws_subnet" "pri-sub" {
  cidr_block = "10.0.12.0/23"
  vpc_id = aws_vpc.new_vpc.id
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "pri-sub"
  }

  
}
resource "aws_internet_gateway" "new-IGW" {
  vpc_id = aws_vpc.new_vpc.id

  tags = {
    Name = "new-IGW"

  }
  
}
resource "aws_route_table" "pub-RT" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-IGW.id

  }
  tags = {
    Name = "pub-RT"
  }
}
resource "aws_route_table" "pri-RT" {
  vpc_id = aws_vpc.new_vpc.id

  tags = {
    Name = "pri-RT"
  }
  
}
resource "aws_route_table_association" "pub-1" {
  subnet_id = aws_subnet.pub-sub.id
  route_table_id = aws_route_table.pub-RT.id

}
resource "aws_route_table_association" "pri-1" {
  subnet_id = aws_subnet.pri-sub.id
  route_table_id = aws_route_table.pri-RT.id
  
}
resource "aws_instance" "pub-instance" {
  subnet_id = aws_subnet.pub-sub.id
  key_name = "k8s-new"
  instance_type = "t2.micro"
  ami = "ami-074f77adfeee318d3"

  tags = {
    Name = "pub-instance"
  }  
}
