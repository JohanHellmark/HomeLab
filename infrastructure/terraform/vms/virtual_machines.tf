resource "proxmox_virtual_environment_vm" "k8s_cp_01" {
  name        = "k8s-cp-01"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "proxmox"

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
    file_id      = proxmox_virtual_environment_file.ubuntu_container_template.id
    ssd          = true
    size         = 30
  }


  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  initialization {
    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id

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

  cpu {
    cores = 3
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_file.ubuntu_container_template.id
    ssd          = true
    size         = 30
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }


  initialization {
    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id


    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker_02" {
  name        = "k8s-worker-02"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "proxmox"

  cpu {
    cores = 3
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_file.ubuntu_container_template.id
    ssd          = true
    size         = 30
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }


  initialization {
    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id


    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "k8s_worker_03" {
  name        = "k8s-worker-03"
  description = "Managed by Terraform"
  tags        = ["terraform", "ubuntu"]
  node_name   = "proxmox"

  cpu {
    cores = 3
  }

  memory {
    dedicated = 2048
  }

  network_device {
    bridge = "vmbr0"
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local"
    interface    = "scsi0"
    file_id      = proxmox_virtual_environment_file.ubuntu_container_template.id
    ssd          = true
    size         = 30
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }


  initialization {
    datastore_id      = "local"
    user_data_file_id = proxmox_virtual_environment_file.cloud_config.id


    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }
}

