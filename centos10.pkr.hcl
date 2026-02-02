packer {
  required_plugins {
    proxmox = {
      source  = "github.com/hashicorp/proxmox"
      version = "~> 1.2"
    }
  }
}

variable "proxmox_url" {}
variable "token_id" {}
variable "token_secret" {}

source "proxmox-iso" "centos10" {
  proxmox_url = var.proxmox_url
  username    = var.token_id
  token       = var.token_secret
  insecure_skip_tls_verify = true

  node    = "proxmox"
  vm_id   = 9003
  vm_name = "centos10-stream-golden"
  os      = "l26"

  template_name = "centos10-stream-golden"

  memory  = 2048
  cores   = 2
  cpu_type = "host"

  scsi_controller = "virtio-scsi-pci"

  # ✅ Disk (v1.2 syntax)
  disks {
    type   = "scsi"
    storage = "local-lvm"
    size   = "20G"
  }

  # ✅ Network
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  # ✅ ISO (v1.2 syntax)
  boot_iso {
    type     = "scsi"
    iso_file = "local:iso/CentOS-Stream-10-latest-x86_64-dvd1.iso"
    unmount  = true
  }

  http_directory = "http"
  boot_wait      = "10s"

  boot_command = [
    "<esc><wait>",
    "linux /images/pxeboot/vmlinuz inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/cent10-ks.cfg ip=dhcp inst.text<enter>",
    "initrd /images/pxeboot/initrd.img<enter>",
    "boot<enter>"
  ]

  ssh_username = "root"
  ssh_password = "anilankem"
  ssh_timeout  = "40m"

  qemu_agent = true
}
