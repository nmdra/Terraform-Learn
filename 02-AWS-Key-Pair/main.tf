terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "web" {
  ami             = "ami-005fc0f236362e99f"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.example.name]
  key_name        = "TF_key"

  tags = {
    Name = "web-server"
  }
}

resource "aws_security_group" "example" {
  name        = "launch-wizard-2"
  vpc_id      = "vpc-061261ce2131c4b86"

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}

output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = aws_instance.web.public_ip
}

output "private_ip" {
  description = "Private IP of instance"
  value       = aws_instance.web.private_ip
}