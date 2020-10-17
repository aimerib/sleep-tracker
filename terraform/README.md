# Terraform and Ansible settings for DO deployment

This repo will:

- Instantiate a new droplet in DO
- Create an inventory file for Ansible
- Run Ansible playbook to
  - configure droplet for non-root user
  - install docker
  - copy docker.env to droplet [1]
  - copy origin certs from Cloudflare to droplet [1]
  - install the DO agent for better metrics

Note that this script relies on having the private and public keys inside a `.ssh` folder. You are going to use when creating the droplet.

If you need to copy a docker.env or certificates to your server, make sure to uncomment that section at the bottom of playbook.yml and edit with the location of your files.

[1]: These have been left commented out, as your usecases might be different than mine.
