variable "droplet_count" {
  description = "Number of droplets to create"
  default     = 1
}

variable "digitalocean_api_token" {
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "pvt_key" {
  description = "SSH private key location"
  default     = "../.ssh/terra"
}

variable "new_user_name" {
  description = "Name for the new user"
  default     = "user"
}

variable "new_user_password" {
  description = "Password for the new user"
  sensitive   = true
  default     = "pass"
}

variable "droplet_name" {
  description = "Droplet Name"
  default     = "new-droplet"
}

variable "droplet_region" {
  description = "Droplet Region"
  default     = "sgp1"
}

variable "droplet_image" {
  description = "OS Image"
  default     = "ubuntu-22-04-x64"
}

variable "droplet_size" {
  description = "Droplet Size"
  default     = "s-1vcpu-512mb-10gb"
}
