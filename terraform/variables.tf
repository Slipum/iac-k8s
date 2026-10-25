variable "proxmox_endpoint" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

variable "template_vm_id" {
  type    = number
  default = 9000
}

variable "ssh_public_key" {
  type = string
}

variable "gateway" {
  type    = string
  default = "<enter_gateway>"
}

variable "k8s_nodes" {
  type = map(object({
    ip       = string
    role     = string
    cores    = number
    memory   = number
    disk_gb  = number
  }))

  default = {
    "k8s-master" = {
      ip      = "<enter_ip>"
      role    = "control-plane"
      cores   = limits
      memory  = limits
      disk_gb = limits
			vm_id   = limits
    }
  }
}