resource "proxmox_virtual_environment_vm" "k8s_cp_01" {
  name        = "k8s-cp-01"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "proxmox"

  clone {
    vm_id = 401
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4092
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    ssd          = true
    size         = 30
  }


  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id      = "local"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker_01" {
  name        = "k8s-worker-01"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "proxmox"

 clone {
    vm_id = 401
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4092
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    ssd          = true
    size         = 30
  }


  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id      = "local"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}
