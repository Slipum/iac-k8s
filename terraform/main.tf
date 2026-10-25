terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

resource "proxmox_virtual_environment_vm" "k8s" {
  for_each = var.k8s_nodes

  node_name = var.proxmox_node
	vm_id     = each.value.vm_id
  name      = each.key
  tags      = ["kubernetes", each.value.role]

  description = "Kubernetes ${each.value.role} node"

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  cpu {
    cores = each.value.cores
    type  = "host"
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk_gb
    ssd          = true
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge  = "<enter_device`>"
    model   = "virtio"
  }

  scsi_hardware = "virtio-scsi-single"

  boot_order = ["scsi0"]

  operating_system {
    type = "l26"
  }

  initialization {
    dns {
      servers = ["1.1.1.1", "8.8.8.8"]
    }

    ip_config {
      ipv4 {
        address = "${each.value.ip}/24"
        gateway = var.gateway
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }

  lifecycle {
    ignore_changes = [
      clone,
      disk,
      network_device
    ]
  }
}

output "node_ips" {
  value = {
    for name, vm in proxmox_virtual_environment_vm.k8s :
    name => vm.ipv4_addresses[1][0]
  }
}