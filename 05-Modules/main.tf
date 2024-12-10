provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source         = "./modules/ec2_instance"
#   ami            = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2 AMI
  instance_type  = "t2.micro"
  key_name       = "my-key-pair"
  instance_name  = "my-ec2-instance"
}

output "ec2_instance_id" {
  value = module.ec2_instance.instance_id
}

output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}