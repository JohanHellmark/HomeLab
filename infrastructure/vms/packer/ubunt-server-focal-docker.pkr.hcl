
# Ubuntu Server Focal Docker
# ---
# Packer Template to create an Ubuntu Server (Focal) with Docker on Proxmox

# Variable Definitions
variable "proxmox_api_url" {
    type = string
}

variable "proxmox_username" {
    type = string
}

variable "proxmox_password" {
    type = string
    sensitive = true
}

# Resource Definiation for the VM Template
source "proxmox-iso" "ubuntu-server-focal-docker" {
    # Proxmox Connection Settings
    proxmox_url = "${var.proxmox_api_url}"
    username = "${var.proxmox_username}"
    password = "${var.proxmox_password}"
    # (Optional) Skip TLS Verification
    insecure_skip_tls_verify = true
    
    # VM General Settings
    node = "proxmox"
    vm_id = "401"
    vm_name = "ubuntu-server-docker"
    template_description = "Ubuntu Server Focal Image with Docker pre-installed"

    # VM OS Settings
    # (Option 1) Local ISO File
    iso_file = "local:iso/ubuntu-20.04.2-live-server-amd64.iso"
    # - or -
    # (Option 2) Download ISO
    # iso_url = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
    # iso_url = "https://releases.ubuntu.com/20.04.2/ubuntu-20.04.2-live-server-amd64.iso"
    # iso_checksum = "5035be37a7e9abbdc09f0d257f3e33416c1a0fb322ba860d42d74aa75c3468d4"
    # iso_storage_pool = "local:iso"
    # unmount_iso = true

    os = "l26"

    # VM System Settings
    # qemu_agent = true

    # VM Hard Disk Settings
    scsi_controller = "virtio-scsi-pci"

    disks {
        disk_size = "30G"
        format = "qcow2"
        storage_pool = "local"
        type = "scsi"
    }

    # VM CPU Settings
    cores = "2"
    
    # VM Memory Settings
    memory = "2048" 

    # VM Network Settings
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        firewall = "false"
    } 

    # VM Cloud-Init Settings
    cloud_init = true
    cloud_init_storage_pool = "local"

    # PACKER Boot Commands
    boot_command = [
        "<esc><wait><esc><wait>",
        "<f6><wait><esc><wait>",
        "<bs><bs><bs><bs><bs>",
        "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ",
        "--- <enter>"
    ]
    # boot_command = ["<esc><wait>", "install <wait>", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>", "debian-installer=en_GB.UTF-8 <wait>", "auto <wait>", 
    #     "locale=en_GB.UTF-8 <wait>", "kbd-chooser/method=gb <wait>", "keyboard-configuration/xkb-keymap=gb <wait>", "netcfg/get_hostname=pkr-template-debian <wait>", "netcfg/get_domain=local.domain <wait>",
    #     "fb=false <wait>", "debconf/frontend=noninteractive <wait>", 
    #     "console-setup/ask_detect=false <wait>", "console-keymaps-at/keymap=gb <wait>", "grub-installer/bootdev=/dev/sda <wait>", "<enter><wait>"]
    # boot_command = ["<enter><wait2><enter><wait><f6><esc><wait>", "autoinstall<wait2> ds=nocloud;", "<wait><enter>"]


    boot = "c"
    boot_wait = "5s"

    # PACKER Autoinstall Settings
    http_directory = "http" 
    # (Optional) Bind IP Address and Port
    http_bind_address = "0.0.0.0"
    http_port_min = 8802
    http_port_max = 8802

    ssh_username = "hellmark"
    # (Option 1) Add your Password here
    # ssh_password = "your-password"
    # - or -
    # (Option 2) Add your Private SSH KEY file here
    ssh_private_key_file = "~/.ssh/id_rsa"

    # Raise the timeout, when installation takes longer
    ssh_timeout = "50m"
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-focal-docker"
    sources = ["proxmox-iso.ubuntu-server-focal-docker"]

    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    # # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
    provisioner "file" {
        source = "files/99-pve.cfg"
        destination = "/tmp/99-pve.cfg"
    }

    # # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    provisioner "shell" {
        inline = ["echo 'Packer Template Build -- Complete'"]
    }

    # Provisioning the VM Template with Docker Installation #4
    provisioner "shell" {
        inline = [
            "sudo apt-get install -y ca-certificates curl gnupg lsb-release",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get -y update",
            "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"
        ]
    }

    # Provisioning the VM Template with kubeadm
    provisioner "shell" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y apt-transport-https ca-certificates curl gpg",
            "sudo mkdir /etc/apt/keyrings/",
            "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
            "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
            "sudo apt-get update",
            "sudo apt-get install -y kubelet kubeadm kubectl",
            "sudo apt-mark hold kubelet kubeadm kubectl",
            "sudo systemctl enable --now kubelet",
            "sudo rm /etc/containerd/config.toml",
            "sudo systemctl restart containerd"
        ]
    }
}