terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "5.10.0"
    }
  }

  backend "s3" {
    bucket         = "s3bucket-alien090078601-712"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    #dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}


provider "aws" {
region = "us-east-1"
 
}

resource "aws_vpc" "main" {

    cidr_block = "10.0.0.0/16"
    tags = {
      Name="main-vpc"
    }
   
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "main-subnet"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "main-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "main" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "main-sg"
  }
}

resource "aws_instance" "web" {
  ami = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  tags = {
    Name="Terraform-Test-2"
  }
}