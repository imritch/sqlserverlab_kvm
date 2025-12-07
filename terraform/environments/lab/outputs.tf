output "vm_ips" {
  description = "IP addresses of all VMs"
  value = {
    for k, v in var.vms : k => v.ip_address
  }
}

output "network_info" {
  description = "Multi-subnet network configuration"
  value = {
    shared_network = {
      name = libvirt_network.shared_network.name
      cidr = var.network_cidrs.shared
    }
    sql_subnet1 = {
      name = libvirt_network.sql_subnet1.name
      cidr = var.network_cidrs.sql1
    }
    sql_subnet2 = {
      name = libvirt_network.sql_subnet2.name
      cidr = var.network_cidrs.sql2
    }
    sql_subnet3 = {
      name = libvirt_network.sql_subnet3.name
      cidr = var.network_cidrs.sql3
    }
    domain = var.domain_name
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
      subnet     = var.vms[k].subnet
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
  description = "SQL Server multi-subnet cluster information"
  value = {
    nodes = [
      for k, v in var.vms : {
        name   = k
        ip     = v.ip_address
        subnet = v.subnet
        fqdn   = "${k}.${var.domain_name}"
      } if v.role == "sql-server"
    ]
    ag_listener_ips = [
      "192.168.101.15",  # SQL Subnet 1
      "192.168.102.15",  # SQL Subnet 2
      "192.168.103.15"   # SQL Subnet 3
    ]
    ag_listener_name = "ag01-listener.${var.domain_name}"
    ag_name          = "AG01"
    cluster_ips = [
      "192.168.101.14",  # Cluster IP in SQL Subnet 1
      "192.168.102.14",  # Cluster IP in SQL Subnet 2
      "192.168.103.14"   # Cluster IP in SQL Subnet 3
    ]
    multi_subnet_note = "Multi-subnet configuration mimics AWS Multi-AZ or Azure Availability Zones"
  }
}
