# Multi-Subnet Network Configuration for SQL Server Multi-Subnet Failover
# Using libvirt provider v0.7.1 schema

# Shared/Management Network - DC01 and App01
resource "libvirt_network" "shared_network" {
  name      = "virbr-lab-shared"
  domain    = var.domain_name
  mode      = "nat"
  addresses = ["192.168.100.1/24"]
  autostart = true
}

# SQL Subnet 1 - SQL01 (Primary)
resource "libvirt_network" "sql_subnet1" {
  name      = "virbr-lab-sql1"
  domain    = var.domain_name
  mode      = "route"
  addresses = ["192.168.101.1/24"]

  dns {
    forwarder {
      address = "192.168.100.10"
    }
  }

  autostart = true
}

# SQL Subnet 2 - SQL02 (Secondary)
resource "libvirt_network" "sql_subnet2" {
  name      = "virbr-lab-sql2"
  domain    = var.domain_name
  mode      = "route"
  addresses = ["192.168.102.1/24"]

  dns {
    forwarder {
      address = "192.168.100.10"
    }
  }

  autostart = true
}

# SQL Subnet 3 - SQL03 (Secondary)
resource "libvirt_network" "sql_subnet3" {
  name      = "virbr-lab-sql3"
  domain    = var.domain_name
  mode      = "route"
  addresses = ["192.168.103.1/24"]

  dns {
    forwarder {
      address = "192.168.100.10"
    }
  }

  autostart = true
}
