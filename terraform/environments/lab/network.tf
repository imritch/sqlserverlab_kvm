# Multi-Subnet Network Configuration for SQL Server Multi-Subnet Failover
# This mimics production cloud environments (AWS Multi-AZ, Azure Availability Zones)

# Shared/Management Network - DC01 and App01
resource "libvirt_network" "shared_network" {
  name      = "virbr-lab-shared"
  mode      = "nat"
  domain    = var.domain_name
  addresses = ["192.168.100.0/24"]

  dhcp {
    enabled = false
  }

  dns {
    enabled    = true
    local_only = true
  }

  autostart = true
}

# SQL Subnet 1 - SQL01 (Primary)
resource "libvirt_network" "sql_subnet1" {
  name      = "virbr-lab-sql1"
  mode      = "route"
  domain    = var.domain_name
  addresses = ["192.168.101.0/24"]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
    # Forward DNS to DC01 on shared network
    forwarders {
      address = "192.168.100.10"
    }
  }

  autostart = true
}

# SQL Subnet 2 - SQL02 (Secondary)
resource "libvirt_network" "sql_subnet2" {
  name      = "virbr-lab-sql2"
  mode      = "route"
  domain    = var.domain_name
  addresses = ["192.168.102.0/24"]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
    forwarders {
      address = "192.168.100.10"
    }
  }

  autostart = true
}

# SQL Subnet 3 - SQL03 (Secondary)
resource "libvirt_network" "sql_subnet3" {
  name      = "virbr-lab-sql3"
  mode      = "route"
  domain    = var.domain_name
  addresses = ["192.168.103.0/24"]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
    forwarders {
      address = "192.168.100.10"
    }
  }

  autostart = true
}
