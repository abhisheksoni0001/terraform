provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "terra-instance" {
    ami = "ami-0d92749d46e71c34c"
    vpc_security_group_ids = ["sg-02dedf164e3d448d5"]
    key_name = "k8s-new"
    availability_zone = "ap-south-1a"
    instance_type = "t2.micro"

    tags = {
        Name = "terraserver"
    } 
}
