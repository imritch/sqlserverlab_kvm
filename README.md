# SQL Server Lab Environment

Automated SQL Server Always On Availability Group lab environment on Ubuntu 24 using KVM/QEMU with **multi-subnet configuration** that mimics production cloud environments (AWS Multi-AZ, Azure Availability Zones).

## Architecture

This lab environment creates:
- **Multi-Subnet Network Design** - 4 isolated subnets for realistic cloud-like deployment
- 1x Active Directory Domain Controller (Windows Server 2022)
- 3x SQL Server nodes in **Multi-Subnet** Windows Failover Cluster (Windows Server 2022)
- 1x Java application server (Linux/Windows)
- SQL Server Developer Edition with **Multi-Subnet** Always On Availability Groups
- Kerberos authentication
- Future: ADCS for TLS certificate management

### Why Multi-Subnet?

This lab uses a multi-subnet architecture to accurately simulate production environments:
- **AWS RDS Multi-AZ**: SQL instances in different availability zones (subnets)
- **Azure SQL AG**: Replicas across different availability zones
- **Production Best Practice**: Subnet isolation for fault tolerance and security
- **Realistic Failover Testing**: Cross-subnet failover scenarios

## System Requirements

- Ubuntu 24.04 LTS
- 64GB RAM (minimum 40GB available for VMs)
- 12 CPU cores
- 500GB free disk space
- KVM/QEMU virtualization support

## VM Resource Allocation

| VM Name | Role | vCPUs | RAM | Disk |
|---------|------|-------|-----|------|
| dc01 | Active Directory DC | 2 | 4GB | 60GB |
| sql01 | SQL Server Node 1 | 4 | 12GB | 100GB |
| sql02 | SQL Server Node 2 | 4 | 12GB | 100GB |
| sql03 | SQL Server Node 3 | 4 | 12GB | 100GB |
| app01 | Java Application | 2 | 4GB | 40GB |

**Total:** 16 vCPUs, 44GB RAM, 400GB Disk

## Prerequisites

Install required tools:
```bash
./scripts/bash/install-prerequisites.sh
```

This installs:
- KVM/QEMU and libvirt
- Terraform with libvirt provider
- Ansible with Windows support
- virt-manager (GUI)
- Other utilities

## Getting Started

### 1. Download Windows Server Evaluation ISOs

```bash
./scripts/bash/download-isos.sh
```

### 2. Initialize Terraform

```bash
cd terraform/environments/lab
terraform init
```

### 3. Deploy Infrastructure

```bash
terraform apply
```

### 4. Configure with Ansible

```bash
cd ../../../ansible
ansible-playbook -i inventory/lab.yml playbooks/site.yml
```

## Project Structure

```
.
├── ansible/
│   ├── playbooks/          # Ansible playbooks
│   ├── roles/              # Ansible roles
│   └── inventory/          # Inventory files
├── terraform/
│   ├── modules/            # Reusable Terraform modules
│   └── environments/lab/   # Lab environment config
├── scripts/
│   ├── bash/               # Bash automation scripts
│   ├── powershell/         # PowerShell scripts for Windows
│   └── sql/                # SQL Server setup scripts
├── docs/                   # Documentation
├── isos/                   # Windows Server ISOs (gitignored)
└── vms/                    # VM disk images (gitignored)
```

## Multi-Subnet Network Configuration

The lab uses **4 separate subnets** to simulate production multi-AZ/multi-zone deployments:

| Subnet Name | CIDR | Purpose | VMs |
|-------------|------|---------|-----|
| **Shared/Management** | 192.168.100.0/24 | Domain Controller, App Server | dc01, app01 |
| **SQL Subnet 1** | 192.168.101.0/24 | SQL Server Primary | sql01 |
| **SQL Subnet 2** | 192.168.102.0/24 | SQL Server Secondary | sql02 |
| **SQL Subnet 3** | 192.168.103.0/24 | SQL Server Secondary | sql03 |

### VM IP Addresses

| Hostname | IP Address | Subnet | FQDN |
|----------|------------|--------|------|
| dc01 | 192.168.100.10 | Shared | dc01.lab.local |
| sql01 | 192.168.101.11 | SQL Subnet 1 | sql01.lab.local |
| sql02 | 192.168.102.12 | SQL Subnet 2 | sql02.lab.local |
| sql03 | 192.168.103.13 | SQL Subnet 3 | sql03.lab.local |
| app01 | 192.168.100.20 | Shared | app01.lab.local |

### Cluster and AG Listener IPs

| Resource | IPs | Purpose |
|----------|-----|---------|
| **Cluster IPs** | 192.168.101.14, 192.168.102.14, 192.168.103.14 | Multi-subnet cluster (one IP per subnet) |
| **AG Listener IPs** | 192.168.101.15, 192.168.102.15, 192.168.103.15 | Multi-subnet AG listener (one IP per subnet) |

**Domain:** lab.local
**DNS:** 192.168.100.10 (dc01)

## SQL Server Multi-Subnet Configuration

- **Instance Name:** MSSQLSERVER (default)
- **Service Account:** lab\sqlservice
- **Cluster Name:** SQLCLUSTER
- **Cluster Type:** Multi-Subnet Windows Failover Cluster
- **Cluster IPs:** 192.168.101.14, 192.168.102.14, 192.168.103.14
- **AG Name:** AG01
- **AG Type:** Multi-Subnet Always On Availability Group
- **AG Listener:** ag01-listener.lab.local
- **AG Listener IPs:** 192.168.101.15, 192.168.102.15, 192.168.103.15 (one per subnet)
- **Databases:** TestDB (configured for multi-subnet AG)
- **Failover:** Automatic failover across subnets (sql01 ↔ sql02), manual for sql03

## Kerberos Configuration

- **Realm:** LAB.LOCAL
- **KDC:** dc01.lab.local
- **SPNs:** Auto-configured for SQL Server instances

## Usage

### Connecting to Multi-Subnet AG from Java App

**IMPORTANT:** Multi-subnet AG connections **require** `multiSubnetFailover=true`:

```java
String connectionUrl = "jdbc:sqlserver://ag01-listener.lab.local:1433;"
    + "databaseName=TestDB;"
    + "integratedSecurity=true;"
    + "authenticationScheme=JavaKerberos;"
    + "multiSubnetFailover=true;";  // REQUIRED for multi-subnet!
```

### Managing VMs

```bash
# List VMs
virsh list --all

# Start/Stop VMs
virsh start dc01
virsh shutdown sql01

# Console access
virsh console dc01
```

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md)

## License

This is a lab environment for learning purposes. Windows Server and SQL Server use evaluation licenses (180 days).

## Roadmap

- [x] Project structure
- [ ] Terraform VM provisioning
- [ ] Active Directory setup
- [ ] Windows Failover Cluster
- [ ] SQL Server installation
- [ ] Always On AG configuration
- [ ] Kerberos authentication
- [ ] Java application deployment
- [ ] ADCS implementation
- [ ] TLS certificate management
