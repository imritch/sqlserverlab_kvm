output "vm_ips" {
  description = "IP addresses of all VMs"
  value = {
    for k, v in var.vms : k => v.ip_address
  }
}

output "network_info" {
  description = "Network configuration"
  value = {
    network_name = libvirt_network.lab_network.name
    cidr         = var.network_cidr
    domain       = var.domain_name
  }
}

output "connection_info" {
  description = "VM connection information"
  value = {
    for k, v in libvirt_domain.vm : k => {
      name       = v.name
      vcpu       = v.vcpu
      memory_mb  = v.memory
      ip_address = var.vms[k].ip_address
    }
  }
}

output "domain_info" {
  description = "Active Directory domain information"
  value = {
    domain_name     = var.domain_name
    domain_netbios  = upper(split(".", var.domain_name)[0])
    dc_ip           = var.vms["dc01"].ip_address
    dc_fqdn         = "dc01.${var.domain_name}"
  }
}

output "sql_cluster_info" {
  description = "SQL Server cluster information"
  value = {
    nodes = [
      for k, v in var.vms : {
        name = k
        ip   = v.ip_address
        fqdn = "${k}.${var.domain_name}"
      } if v.role == "sql-server"
    ]
    ag_listener_ip = "192.168.100.15"
    ag_name        = "AG01"
  }
}
