# resource "proxmox_virtual_environment_file" "ubuntu_container_template" {
#   content_type = "iso"
#   datastore_id = "local"
#   node_name    = "proxmox"

#   source_file {
#     path = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
#   }
# }

# resource "proxmox_virtual_environment_file" "cloud_config" {
#   content_type = "snippets"
#   datastore_id = "local"
#   node_name    = "proxmox"

#   source_file {
#     path = "cloud-init/user-data.yaml"
#   }
# }
