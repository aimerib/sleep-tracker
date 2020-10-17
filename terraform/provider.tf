terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "1.22.2"
    }
  }
}

variable "do_token" {}
variable "ssh_fingerprint" {}
variable "private_key" {}

provider "digitalocean" {
  token = var.do_token
}
