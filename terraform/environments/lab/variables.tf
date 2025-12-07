variable "domain_name" {
  description = "Active Directory domain name"
  type        = string
  default     = "lab.local"
}

variable "network_cidrs" {
  description = "Network CIDRs for multi-subnet lab environment"
  type = object({
    shared = string
    sql1   = string
    sql2   = string
    sql3   = string
  })
  default = {
    shared = "192.168.100.0/24"
    sql1   = "192.168.101.0/24"
    sql2   = "192.168.102.0/24"
    sql3   = "192.168.103.0/24"
  }
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

variable "sql_installer_path" {
  description = "Path to SQL Server 2025 bootstrap installer"
  type        = string
  default     = "../../../isos/SQL2025-SSEI-EntDev.exe"
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
    subnet     = string  # which subnet the VM belongs to
    vcpu       = number
    memory     = number # in MB
    disk_size  = number # in GB
    role       = string
  }))

  default = {
    dc01 = {
      ip_address = "192.168.100.10"
      subnet     = "shared"
      vcpu       = 2
      memory     = 4096
      disk_size  = 60
      role       = "domain-controller"
    }
    sql01 = {
      ip_address = "192.168.101.11"
      subnet     = "sql1"
      vcpu       = 4
      memory     = 12288
      disk_size  = 100
      role       = "sql-server"
    }
    sql02 = {
      ip_address = "192.168.102.12"
      subnet     = "sql2"
      vcpu       = 4
      memory     = 12288
      disk_size  = 100
      role       = "sql-server"
    }
    sql03 = {
      ip_address = "192.168.103.13"
      subnet     = "sql3"
      vcpu       = 4
      memory     = 12288
      disk_size  = 100
      role       = "sql-server"
    }
    app01 = {
      ip_address = "192.168.100.20"
      subnet     = "shared"
      vcpu       = 2
      memory     = 4096
      disk_size  = 40
      role       = "application"
    }
  }
}
