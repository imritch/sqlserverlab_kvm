# Getting Started with SQL Server Lab

This guide will walk you through setting up the complete SQL Server Always On lab environment.

## Prerequisites

- Ubuntu 24.04 LTS
- 64GB RAM
- 12 CPU cores
- 500GB free disk space
- Virtualization enabled in BIOS

## Step-by-Step Setup

### Step 1: Install Required Tools

```bash
./scripts/bash/install-prerequisites.sh
```

This installs:
- KVM/QEMU virtualization
- libvirt
- Terraform
- Ansible
- virt-manager (GUI)

**Important:** After installation, log out and log back in for group membership changes to take effect.

### Step 2: Verify Installation

```bash
# Check KVM
kvm-ok

# Check libvirt
virsh version

# Check Terraform
terraform version

# Check Ansible
ansible --version

# Check Python WinRM
python3 -c "import winrm; print('WinRM OK')"
```

### Step 3: Download ISOs

```bash
./scripts/bash/download-isos.sh
```

You'll need:
1. **Windows Server 2022 Evaluation** (~5GB)
   - Download from: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022
   - Save as: `isos/windows-server-2022.iso`

2. **SQL Server 2025 Developer Edition** (~2GB)
   - Download from: https://www.microsoft.com/en-us/sql-server/sql-server-downloads
   - Save as: `isos/SQLServer2025-DEV-x64-ENU.iso`

### Step 4: Review and Customize Configuration

Edit these files if needed:

**Terraform variables** (`terraform/environments/lab/variables.tf`):
- Network configuration
- VM resource allocation
- Admin password (change default!)

**Ansible inventory** (`ansible/inventory/lab.yml`):
- Domain name
- Service account passwords (change defaults!)
- SQL Server configuration

### A Note on Terraform Provider and Base Images

Before deploying the infrastructure, it's crucial to understand two key points about the Terraform setup in this project.

**1. Terraform Provider:**

The Terraform configuration is written for the `dmacvicar/libvirt` provider, not the official `libvirt/libvirt` provider. The syntax for defining resources, especially `libvirt_volume`, is specific to this provider. The errors related to `source` and `base_volume_id` being unsupported were due to a syntax mismatch, which has now been corrected in the `main.tf` file.

**2. Windows Base Image (`.qcow2`):**
While working with Claude on this I was trying to use the Windows Server 2022 .iso file directly to create the infra using Terraform. 
That kept failing and eventually it got clear that I would first have to create a VM using the .iso file and create a base image.  
Once the base image is created Terrform will create new virtual machines by cloning a "base image" or "template". 

**How to Create the Windows `.qcow2` Base Image:**

1.  **Use `virt-manager` to create a new VM.**
2.  During creation, select the Windows Server 2022 `.iso` as the installation media.
3.  When prompted for the edition, choose **Windows Server 2022 Datacenter Evaluation (Desktop Experience)**. This provides a GUI, which is much easier for managing SQL Server.
4.  Install the OS as you normally would. After the initial installation and before running `sysprep`, it is highly recommended to install the `virtio` drivers for optimal network and disk performance.

5.  **Install VirtIO Drivers:**
    *   **Download:** Get the latest stable `virtio-win.iso` file from the official Fedora repository: [https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)
    *   **Attach ISO:** In `virt-manager`, view the VM's details and select the "SATA CDROM" device. Connect and attach the `virtio-win.iso` file you just downloaded.
    *   **Update Drivers:** Inside the Windows VM, open **Device Manager**. You will see several devices (like "Ethernet Controller" and "PCI Device") with yellow warning icons. For each of these devices:
        *   Right-click the device and select **Update driver**.
        *   Choose **Browse my computer for drivers**.
        *   Browse to the CD-ROM drive (labeled "virtio-win"), ensure **"Include subfolders"** is checked, and click **Next**. Windows will find and install the driver.
    *   **Install Guest Agent:** From File Explorer, open the CD-ROM and run the `virtio-win-guest-tools.exe` installer to improve VM integration.

6.  After installation and any other customizations (like installing Windows Updates), you must **generalize** the image using `sysprep`. This prepares it for cloning. Open a Command Prompt as an Administrator and run:
    ```
    C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /mode:vm
    ```
7.  The VM will shut down. **Do not start it again.** The disk file for this VM (e.g., `/var/lib/libvirt/images/windows-server-2022-base.qcow2`) is now your base image.
8.  Update the `iso_path_windows` variable in `terraform/environments/lab/variables.tf` to point to the path of this new `.qcow2` file.

### Step 5: Deploy Infrastructure with Terraform

```bash
cd terraform/environments/lab

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply (create VMs)
terraform apply
```

This creates:
- Virtual network (192.168.100.0/24)
- 5 VMs (dc01, sql01, sql02, sql03, app01)
- Storage pool for VM disks

**Time estimate:** 30-45 minutes

### Step 6: Configure with Ansible

```bash
cd ../../../ansible

# Run the main playbook
ansible-playbook -i inventory/lab.yml playbooks/site.yml
```

This will:
1. Configure Active Directory Domain Controller
2. Create domain users and service accounts
3. Join SQL nodes to domain
4. Create Windows Failover Cluster
5. Install SQL Server on all nodes
6. Configure Always On Availability Groups
7. Set up Kerberos authentication
8. Deploy Java application server

**Time estimate:** 60-90 minutes

### Step 7: Verify Deployment

```bash
ansible-playbook -i inventory/lab.yml playbooks/09-verify-deployment.yml
```

## What Gets Created

### Network Infrastructure
- **Network:** 192.168.100.0/24
- **DNS/Gateway:** Provided by libvirt NAT
- **Domain DNS:** dc01 (192.168.100.10)

### Virtual Machines

| VM | Role | IP | vCPU | RAM | Disk |
|----|------|-------|------|-----|------|
| dc01 | AD Domain Controller | 192.168.100.10 | 2 | 4GB | 60GB |
| sql01 | SQL Server Node 1 (Primary) | 192.168.100.11 | 4 | 12GB | 100GB |
| sql02 | SQL Server Node 2 (Secondary) | 192.168.100.12 | 4 | 12GB | 100GB |
| sql03 | SQL Server Node 3 (Secondary) | 192.168.100.13 | 4 | 12GB | 100GB |
| app01 | Java Application Server | 192.168.100.20 | 2 | 4GB | 40GB |

### Active Directory
- **Domain:** lab.local
- **NetBIOS:** LAB
- **Functional Level:** Windows Server 2022
- **Service Accounts:**
  - LAB\sqlservice (SQL Server service)
  - LAB\sqlagent (SQL Agent service)

### SQL Server Cluster
- **Cluster Name:** SQLCLUSTER
- **Cluster IP:** 192.168.100.14
- **Quorum:** Node Majority

### Always On Availability Group
- **AG Name:** AG01
- **Listener:** ag01-listener.lab.local
- **Listener IP:** 192.168.100.15
- **Configuration:**
  - sql01: Primary, Synchronous, Auto-Failover
  - sql02: Secondary, Synchronous, Auto-Failover
  - sql03: Secondary, Asynchronous, Manual-Failover

### Kerberos
- **Realm:** LAB.LOCAL
- **KDC:** dc01.lab.local
- **SPNs:** Registered for all SQL instances and AG listener

## Accessing the Environment

### Using virt-manager (GUI)

```bash
virt-manager
```

Connect to VMs via VNC console.

### Using virsh (CLI)

```bash
# List all VMs
virsh list --all

# Start a VM
virsh start dc01

# Connect to console
virsh console dc01

# Shutdown a VM
virsh shutdown sql01

# Get VM info
virsh dominfo sql01
```

### Remote Desktop (RDP)

From your Ubuntu host:

```bash
# Install RDP client
sudo apt install remmina

# Connect to a VM
remmina -c rdp://192.168.100.10
```

Credentials:
- Username: `Administrator`
- Password: `P@ssw0rd123!` (or whatever you set)

### SQL Server Management

From Windows VMs using PowerShell:

```powershell
# Connect via AG listener
Invoke-Sqlcmd -ServerInstance "ag01-listener.lab.local" -Query "SELECT @@SERVERNAME"

# Check AG status
Invoke-Sqlcmd -ServerInstance "sql01" -Query @"
SELECT
    ag.name AS AvailabilityGroup,
    ar.replica_server_name AS Replica,
    ars.role_desc AS Role
FROM sys.availability_groups ag
JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
JOIN sys.dm_hadr_availability_replica_states ars ON ar.replica_id = ars.replica_id
"@

# Test failover
Invoke-Sqlcmd -ServerInstance "sql01" -Query "ALTER AVAILABILITY GROUP AG01 FAILOVER"
```

## Testing Kerberos Authentication

### From the Java Application Server

```bash
# SSH to app server
ssh ubuntu@192.168.100.20

# Get Kerberos ticket (if domain-joined or using keytab)
kinit appuser@LAB.LOCAL

# Verify ticket
klist

# Run the test application
/opt/sqlapp/run.sh
```

### From Linux Host (if domain-joined)

```bash
# Install SQL Server command line tools
# Follow: https://learn.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools

# Test connection
sqlcmd -S ag01-listener.lab.local -d TestDB -E
```

## Connection Strings

### From Windows (Integrated Auth)
```
Server=ag01-listener.lab.local,1433;Database=TestDB;Integrated Security=true;
```

### From Java (Kerberos)
```java
String url = "jdbc:sqlserver://ag01-listener.lab.local:1433;" +
             "databaseName=TestDB;" +
             "integratedSecurity=true;" +
             "authenticationScheme=JavaKerberos;";
```

### From .NET (Integrated Auth)
```csharp
var connectionString = "Server=ag01-listener.lab.local,1433;Database=TestDB;Integrated Security=true;";
```

## Troubleshooting

See [troubleshooting.md](troubleshooting.md) for common issues and solutions.

## Next Steps

1. **Add more databases to AG**
2. **Test failover scenarios**
3. **Configure backup strategy**
4. **Set up SQL Server Agent jobs**
5. **Implement ADCS for TLS certificates**
6. **Configure monitoring and alerts**

## Cleanup

To destroy the entire lab:

```bash
cd terraform/environments/lab
terraform destroy
```

This removes all VMs and networks but keeps the ISOs and configuration files.
