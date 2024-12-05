resource "digitalocean_droplet" "my-droplet" {
  count  = var.droplet_count
  name   = "${var.droplet_name}-${count.index + 1}"
  region = var.droplet_region
  size   = var.droplet_size
  image  = var.droplet_image

  ssh_keys = [
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
    ]
  }
}
