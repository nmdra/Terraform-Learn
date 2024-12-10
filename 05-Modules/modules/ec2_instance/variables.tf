variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
    default = "ami-005fc0f236362e99f"
}

variable "instance_type" {
  description = "The type of instance to create"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
}

variable "instance_name" {
  description = "The name tag for the instance"
  type        = string
  default     = "example-instance"
}
