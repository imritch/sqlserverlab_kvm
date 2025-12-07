# Storage pool for VM disks
resource "libvirt_pool" "vm_pool" {
  name = "sqlserver-lab-pool"
  type = "dir"
  path = "/var/lib/libvirt/images/sqlserver-lab"
}

# Windows Server base image
resource "libvirt_volume" "windows_base" {
  name   = "windows-server-2022-base.qcow2"
  pool   = libvirt_pool.vm_pool.name
  source = abspath(var.iso_path_windows)
  format = "qcow2"
}

# Create VM volumes from base image
resource "libvirt_volume" "vm_disk" {
  for_each = var.vms

  name           = "${each.key}-disk.qcow2"
  pool           = libvirt_pool.vm_pool.name
  base_volume_id = each.value.role != "application" ? libvirt_volume.windows_base.id : null
  size           = each.value.disk_size * 1024 * 1024 * 1024 # Convert GB to bytes
  format         = "qcow2"
}

# Cloud-init / unattend.xml configuration
# For Windows, we'll use unattend.xml via cdrom
data "template_file" "unattend_xml" {
  for_each = { for k, v in var.vms : k => v if v.role != "application" }

  template = file("${path.module}/templates/unattend.xml.tpl")

  vars = {
    hostname       = each.key
    admin_password = var.admin_password
    ip_address     = each.value.ip_address
    gateway        = "192.168.100.1"
    dns_server     = "192.168.100.10"
    domain_name    = var.domain_name
  }
}

# Create cloudinit disk for Windows unattend
resource "libvirt_cloudinit_disk" "unattend" {
  for_each = { for k, v in var.vms : k => v if v.role != "application" }

  name      = "${each.key}-unattend.iso"
  pool      = libvirt_pool.vm_pool.name
  user_data = data.template_file.unattend_xml[each.key].rendered
}

# Define VMs
resource "libvirt_domain" "vm" {
  for_each = var.vms

  name   = each.key
  memory = each.value.memory
  vcpu   = each.value.vcpu

  cpu {
    mode = "host-passthrough"
  }

  firmware = "/usr/share/OVMF/OVMF_CODE.fd"

  disk {
    volume_id = libvirt_volume.vm_disk[each.key].id
  }

  # Attach unattend ISO for Windows VMs
  dynamic "disk" {
    for_each = each.value.role != "application" ? [1] : []
    content {
      file = "/var/lib/libvirt/images/sqlserver-lab/${each.key}-unattend.iso"
    }
  }

  network_interface {
    network_id     = libvirt_network.lab_network.id
    hostname       = each.key
    addresses      = [each.value.ip_address]
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  # Boot from disk after installation
  boot_device {
    dev = ["hd", "cdrom"]
  }

  autostart = false

  depends_on = [
    libvirt_volume.vm_disk
  ]
}
