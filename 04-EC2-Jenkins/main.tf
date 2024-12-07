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

resource "aws_instance" "Jenkins" {
  ami             = "ami-0453ec754f44f9a4a"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.Jenkins-sg.name]
  key_name        = "TF_key"
  #   user_data       = file("./install.sh")

  tags = {
    Name = "Jenkins-server"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.rsa.private_key_pem
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
      "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key",
      "sudo yum upgrade",
      "sudo yum install java-17-amazon-corretto -y",
      "sudo yum install jenkins -y",
      "sudo systemctl enable jenkins",
      "sudo systemctl start jenkins",
      "sleep 5",
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
    ]
  }

}

resource "aws_security_group" "Jenkins-sg" {
  name   = "launch-wizard-2"
  vpc_id = "vpc-061261ce2131c4b86"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

output "public_ip" {
  description = "Public IP of instance (or EIP)"
  value       = aws_instance.Jenkins.public_ip
}

output "private_ip" {
  description = "Private IP of instance"
  value       = aws_instance.Jenkins.private_ip
}