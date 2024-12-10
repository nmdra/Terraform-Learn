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

resource "aws_s3_bucket" "example" {
  bucket = "${random_pet.bucket_suffix.id}-${random_uuid.test.result}"

  depends_on = [aws_instance.web]
  tags = {
    Name        = "${random_pet.bucket_suffix.id}-${random_uuid.test.result}"
    Environment = "Dev"
  }
}


resource "aws_instance" "web" {
  ami             = "ami-005fc0f236362e99f"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.example.name]
  key_name        = "TF_key"

  tags = {
    Name = "${random_pet.bucket_suffix.id}-${random_uuid.test.result}"
  }
}

resource "aws_security_group" "example" {
  name   = "${random_pet.bucket_suffix.id}-${random_uuid.test.result}"
  vpc_id = "vpc-061261ce2131c4b86"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
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

  lifecycle {
    prevent_destroy = false
  }
}

resource "random_uuid" "test" {
}

# Generate a random pet name for suffix 
resource "random_pet" "bucket_suffix" {
  length = 2
}

output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = aws_instance.web.public_ip
}

output "private_ip" {
  description = "Private IP of instance"
  value       = aws_instance.web.private_ip
}