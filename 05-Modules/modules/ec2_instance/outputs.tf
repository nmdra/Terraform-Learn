output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.this.public_ip
}
