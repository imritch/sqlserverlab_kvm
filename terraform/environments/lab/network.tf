# Create a network for the lab environment
resource "libvirt_network" "lab_network" {
  name      = var.network_bridge
  mode      = "nat"
  domain    = var.domain_name
  addresses = [var.network_cidr]

  dhcp {
    enabled = false
  }

  dns {
    enabled    = true
    local_only = true

    # Initially point to gateway, will be updated to DC after DC setup
    # forwarders {
    #   address = "192.168.100.10"
    # }
  }

  autostart = true
}
