variable "domain_name" {
  description = "Active Directory domain name"
  type        = string
  default     = "lab.local"
}

variable "network_cidr" {
  description = "Network CIDR for lab environment"
  type        = string
  default     = "192.168.100.0/24"
}

variable "network_bridge" {
  description = "Network bridge name"
  type        = string
  default     = "virbr-lab"
}

variable "vm_storage_pool" {
  description = "Libvirt storage pool for VM disks"
  type        = string
  default     = "default"
}

variable "iso_path_windows" {
  description = "Path to Windows Server 2022 ISO"
  type        = string
  default     = "../../../isos/windows-server-2022.iso"
}

variable "iso_path_sqlserver" {
  description = "Path to SQL Server 2022 ISO"
  type        = string
  default     = "../../../isos/SQLServer2022-DEV-x64-ENU.iso"
}

variable "admin_password" {
  description = "Windows Administrator password"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd123!" # Change this!
}

variable "vms" {
  description = "VM configurations"
  type = map(object({
    ip_address = string
    vcpu       = number
    memory     = number # in MB
    disk_size  = number # in GB
    role       = string
  }))

  default = {
    dc01 = {
      ip_address = "192.168.100.10"
      vcpu       = 2
      memory     = 4096
      disk_size  = 60
      role       = "domain-controller"
    }
    sql01 = {
      ip_address = "192.168.100.11"
      vcpu       = 4
      memory     = 12288
      disk_size  = 100
      role       = "sql-server"
    }
    sql02 = {
      ip_address = "192.168.100.12"
      vcpu       = 4
      memory     = 12288
      disk_size  = 100
      role       = "sql-server"
    }
    sql03 = {
      ip_address = "192.168.100.13"
      vcpu       = 4
      memory     = 12288
      disk_size  = 100
      role       = "sql-server"
    }
    app01 = {
      ip_address = "192.168.100.20"
      vcpu       = 2
      memory     = 4096
      disk_size  = 40
      role       = "application"
    }
  }
}
