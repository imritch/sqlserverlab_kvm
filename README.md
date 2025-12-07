# SQL Server Lab Environment

Automated SQL Server Always On Availability Group lab environment on Ubuntu 24 using KVM/QEMU.

## Architecture

This lab environment creates:
- 1x Active Directory Domain Controller (Windows Server 2022)
- 3x SQL Server nodes in Windows Failover Cluster (Windows Server 2022)
- 1x Java application server (Linux/Windows)
- SQL Server Developer Edition with Always On Availability Groups
- Kerberos authentication
- Future: ADCS for TLS certificate management

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

## Network Configuration

- Network: 192.168.100.0/24
- Gateway: 192.168.100.1
- Domain: lab.local
- DNS: 192.168.100.10 (dc01)

| Hostname | IP Address | FQDN |
|----------|------------|------|
| dc01 | 192.168.100.10 | dc01.lab.local |
| sql01 | 192.168.100.11 | sql01.lab.local |
| sql02 | 192.168.100.12 | sql02.lab.local |
| sql03 | 192.168.100.13 | sql03.lab.local |
| app01 | 192.168.100.20 | app01.lab.local |

## SQL Server Configuration

- **Instance Name:** MSSQLSERVER (default)
- **Service Account:** lab\sqlservice
- **AG Name:** AG01
- **AG Listener:** ag01-listener.lab.local (192.168.100.15)
- **Databases:** Initially empty, configured for AG

## Kerberos Configuration

- **Realm:** LAB.LOCAL
- **KDC:** dc01.lab.local
- **SPNs:** Auto-configured for SQL Server instances

## Usage

### Connecting to SQL Server from Java App

```java
String connectionUrl = "jdbc:sqlserver://ag01-listener.lab.local:1433;"
    + "databaseName=TestDB;"
    + "integratedSecurity=true;"
    + "authenticationScheme=JavaKerberos;";
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
