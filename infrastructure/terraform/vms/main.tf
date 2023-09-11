terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.30.3"
    }
  }
}

provider "proxmox" {
  insecure = true
  ssh {
    agent = false
  }
}
