packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = "~> 1.1"
    }
  }
}

variable "proxmox_url" {}
variable "token_id" {}
variable "token_secret" {}

source "proxmox-iso" "rocky" {
  proxmox_url              = var.proxmox_url
  username                 = var.token_id
  token                    = var.token_secret
  insecure_skip_tls_verify = true

  node     = "proxmox"
  vm_id    = 9002
  vm_name  = "rocky-9-golden"

  # ✅ HashiCorp field name
  cpu      = "host"
  cores    = 2
  memory   = 2048
  os       = "other"

  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # ✅ HashiCorp disk block keys
  disks {
    storage_pool = "local-lvm"
    type         = "scsi"
    size         = "20G"
  }

  # ✅ HashiCorp ISO style (split)
  iso_storage_pool = "local"
  iso_file         = "Rocky-9-latest-x86_64-boot.iso"
  unmount_iso      = true

  ssh_username = "root"
  ssh_password = "rocky"
  ssh_timeout  = "30m"
}

build {
  sources = ["source.proxmox-iso.rocky"]

  provisioner "shell" {
    inline = [
      "dnf -y update",
      "dnf -y install openssh-server qemu-guest-agent cloud-init sudo",
      "systemctl enable sshd",
      "systemctl enable qemu-guest-agent",
      "cloud-init clean",
      "truncate -s 0 /etc/machine-id",
      "rm -f /var/lib/dbus/machine-id",
      "rm -rf /var/lib/cloud/*",
      "shutdown -h now"
    ]
  }
}
