terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "droplet_count" {
  description = "Number of droplets to create"
  default     = 1
}

variable "digitalocean_api_token" {
  description = "DigitalOcean API token"
  sensitive   = true
}
# variable "ssh_fingerprint" {
#   description = "Fingerprint of your SSH key"
#   sensitive = true
# }
variable "pvt_key" {
  description = "SSH private key location"
  default     = "../.ssh/terra"
}
variable "new_user_name" {
  description = "name for the new user"
  sensitive   = false
  default     = "user"
}
variable "new_user_password" {
  description = "Password for the new user"
  sensitive   = true
  default     = "pass"
}
variable "droplet_name" {
  description = "Droplet Name"
  sensitive   = false
  default     = "new-droplet"
}
variable "droplet_region" {
  description = "Droplet Region"
  sensitive   = false
  default     = "sgp1"
}
variable "droplet_image" {
  description = "OS Image"
  sensitive   = false
  default     = "ubuntu-22-04-x64"
}
variable "droplet_size" {
  description = "Droplet Size"
  sensitive   = false
  default     = "s-1vcpu-512mb-10gb"
}

data "digitalocean_ssh_key" "key" {
  name = "terraform"
}

provider "digitalocean" {
  token = var.digitalocean_api_token
}

resource "digitalocean_droplet" "my-droplet" {
  count = var.droplet_count
  name   = "${var.droplet_name}-${count.index + 1}"
  region = "${var.droplet_region}"
  size   = "${var.droplet_size}"
  image  = "${var.droplet_image}"

  ssh_keys = [
    # var.ssh_fingerprint
    data.digitalocean_ssh_key.key.id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo adduser --disabled-password --gecos '' ${var.new_user_name}",
      "echo '${var.new_user_name}:${var.new_user_password}' | sudo chpasswd",
      "sudo usermod -aG sudo ${var.new_user_name}",
      "sudo mkdir -p /home/${var.new_user_name}/.ssh",
      "sudo chmod 700 /home/${var.new_user_name}/.ssh",
      "sudo cp /root/.ssh/authorized_keys /home/${var.new_user_name}/.ssh/",
      "sudo chmod 600 /home/${var.new_user_name}/.ssh/authorized_keys",
      "sudo chown -R ${var.new_user_name}:${var.new_user_name} /home/${var.new_user_name}/.ssh",
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "curl -fsSL https://get.docker.com -o install-docker.sh",
      "sudo sh install-docker.sh",
      "sudo groupadd docker",
      "sudo usermod -aG docker ${var.new_user_name}",
      # "sudo docker volume create portainer_data",
      # "docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.4",
    ]
  }
}

output "droplet_ip" {
  description = "SSH access details for the droplet"
  value = [
    for droplet in digitalocean_droplet.my-droplet : {
      name                = droplet.name
      ip_address          = droplet.ipv4_address
      image               = droplet.image
      private_key_location = var.pvt_key
    }
  ]
}
