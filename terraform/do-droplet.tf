resource "digitalocean_droplet" "do-droplet" {
  image = "ubuntu-20-04-x64"
  name = "sleep-tracker"
  region = "nyc3"
  size = "s-1vcpu-1gb"
  private_networking = true
  ssh_keys = [var.ssh_fingerprint]
}

resource "null_resource" "ansible-provision" {
  depends_on = [
    digitalocean_droplet.do-droplet,
  ]
}

output "ip" {
  value = digitalocean_droplet.do-droplet.ipv4_address
}

resource "null_resource" "inventory_create" {

  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
    echo "all:
      hosts:
        ${digitalocean_droplet.do-droplet.name}:
          ansible_host: ${digitalocean_droplet.do-droplet.ipv4_address}
          ansible_ssh_user: root
          ansible_ssh_private_key_file: ${var.private_key}" > inventory.yml
    EOT
  }
}

