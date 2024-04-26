terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

### EC2 ###

resource "aws_instance" "marcusServer" {
  ami = "ami-016eb5d644c333ccb"
  instance_type = "t2.micro"
  
  subnet_id = aws_subnet.marcuSubnet.id

  key_name = "id_rsa"
  

  tags = {
    Name = "marcusServer"
  }
}


### VPC ###

resource "aws_vpc" "marcusVPC" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "Marcus VPC"
  }
}

### Subnet ###
resource "aws_subnet" "marcuSubnet" {
  vpc_id     = aws_vpc.marcusVPC.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Marcus Subnet"
  }
}

### Internet Gateway ###
resource "aws_internet_gateway" "marcusGW" {
  vpc_id = aws_vpc.marcusVPC.id

  tags = {
    Name = "marcusVPC"
  }
}

### RT ###

resource "aws_route_table" "marcusRT" {
  vpc_id = aws_vpc.marcusVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.marcusGW.id
  }

  tags = {
    Name = "RT-MARCUS"
  }
}

### RT Association Subnet ###

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.marcuSubnet.id
  route_table_id = aws_route_table.marcusRT.id
}



### SG ###

resource "aws_security_group" "allow_tudo" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.marcusVPC.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tudo"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id = aws_security_group.allow_tudo.id
  network_interface_id = aws_instance.marcusServer.primary_network_interface_id
  
}

