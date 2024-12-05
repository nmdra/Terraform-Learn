output "droplet_ip" {
  description = "SSH access details for the droplet"
  value = [
    for droplet in digitalocean_droplet.my-droplet : {
      name                 = droplet.name
      ip_address           = droplet.ipv4_address
      image                = droplet.image
      private_key_location = var.pvt_key
    }
  ]
}
