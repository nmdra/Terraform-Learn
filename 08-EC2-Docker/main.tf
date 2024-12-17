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

resource "aws_instance" "Swarm" {
  for_each        = toset(["mgr1"])
  ami             = "ami-01816d07b1128cd2d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.Swarm-sg.name]
  key_name        = "TF_key"

  tags = {
    Name = "Swarm-${each.key}"
  }

  user_data = <<-EOF
              #cloud-config
              package_update: true
              package_upgrade: true

              packages:
                - docker

              runcmd:
                - sudo systemctl enable docker
                - sudo systemctl start docker
                - sudo usermod -aG docker ec2-user

              final_message: "Docker installation completed successfully on $(hostname)"
              EOF
}

locals {
  ingress_rules = [
    { from_port = 22, to_port = 22, protocol = "tcp" },
    { from_port = 8080, to_port = 8080, protocol = "tcp" },
    { from_port = 80, to_port = 80, protocol = "tcp" },
    { from_port = 443, to_port = 443, protocol = "tcp" },
  ]

  egress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1" },
  ]
}

resource "aws_security_group" "Swarm-sg" {
  name   = "launch-wizard-2"
  vpc_id = data.aws_vpc.default.id

  dynamic "ingress" {
    for_each = local.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

output "public_ips" {
  description = "Public IPs of all Swarm instances"
  value       = { for name, instance in aws_instance.Swarm : name => instance.public_ip }
}

output "private_ips" {
  description = "Private IPs of all Swarm instances"
  value       = { for name, instance in aws_instance.Swarm : name => instance.private_ip }
}
