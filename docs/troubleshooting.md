# Troubleshooting Guide

Common issues and their solutions.

## Terraform Issues

### Sysprep Fails with "was not able to validate your Windows installation"

When creating the `.qcow2` base image, the `sysprep` command can fail with a validation error. This is commonly caused by a modern Windows App (UWP) that was updated for the logged-in user but not provisioned for all users.

**Error Log:**

You can diagnose which app is causing the failure by checking the log file at `C:\Windows\System32\Sysprep\Panther\setupact.log`. You are looking for an error like this:

```
2025-12-07 17:50:59, Error                 SYSPRP Package Microsoft.MicrosoftEdge.Stable_143.0.3650.66_neutral__8wekyb3d8bbwe was installed for a user, but not provisioned for all users. This package will not function properly in the sysprep image.
2025-12-07 17:50:59, Error                 SYSPRP Failed to remove apps for the current user: 0x80073cf2.
```

**Solution:**

You must remove the problematic package using PowerShell. Open PowerShell as an Administrator and run the following commands. This example is for the `Microsoft.MicrosoftEdge.Stable` package, which is a common culprit.

1.  **Remove the package for the current user:**
    ```powershell
    Get-AppxPackage -Name Microsoft.MicrosoftEdge.Stable | Remove-AppxPackage
    ```

2.  **Remove the provisioned package for the system:**
    ```powershell
    Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*Microsoft.MicrosoftEdge.Stable*" } | Remove-AppxProvisionedPackage -Online
    ```

After running these commands, you can try the `sysprep` command again.
```
C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /shutdown /mode:vm
```

### Error: "libvirt provider not found"

**Solution:**
```bash
cd terraform/environments/lab
terraform init
```

### Error: "Permission denied" when creating VMs

**Solution:**
Ensure you're in the libvirt group:
```bash
sudo usermod -aG libvirt,kvm $USER
# Log out and log back in
```

Verify:
```bash
groups | grep libvirt
```

### VMs fail to start

**Solution:**
Check libvirt logs:
```bash
sudo journalctl -u libvirtd -f
```

Verify KVM support:
```bash
kvm-ok
ls -la /dev/kvm
```

## Ansible Issues

### WinRM connection failures

**Error:** `Connection refused` or `Connection timeout`

**Solution:**
1. Verify VM is running: `virsh list`
2. Check VM IP: `virsh domifaddr dc01`
3. Wait for Windows to boot (can take 5-10 minutes on first boot)
4. Test WinRM manually:
```bash
curl -u 'Administrator:P@ssw0rd123!' --header 'Content-Type: application/soap+xml;charset=UTF-8' --data '' http://192.168.100.10:5985/wsman
```

### Authentication failures

**Error:** `401 Unauthorized`

**Solution:**
Check credentials in `ansible/inventory/lab.yml`. Ensure password matches what was set in `terraform/environments/lab/variables.tf`.

### "Module pywinrm not found"

**Solution:**
```bash
pip3 install --user pywinrm
```

## Active Directory Issues

### Domain creation fails

**Solution:**
1. Check DNS is working in the DC
2. Verify VM has enough resources (minimum 4GB RAM)
3. Check logs on DC via console:
```powershell
Get-EventLog -LogName "Directory Service" -Newest 50
```

### Cannot join nodes to domain

**Solution:**
1. Verify DNS on nodes points to DC (192.168.100.10)
2. Ping domain controller from node
3. Check firewall rules
4. Verify domain controller is fully operational:
```powershell
Get-ADDomain
Get-Service NTDS, DNS
```

## Failover Cluster Issues

### Cluster validation fails

**Solution:**
Review validation report:
```powershell
Test-Cluster -Node sql01,sql02,sql03 | Out-File C:\cluster-validation.html
```

Common issues:
- Ensure all nodes can communicate
- Verify same domain membership
- Check firewall rules for cluster ports

### Cluster creation fails

**Solution:**
```powershell
# Remove failed cluster
Remove-Cluster -Force -CleanupAD

# Try again
New-Cluster -Name SQLCLUSTER -Node sql01,sql02,sql03 -StaticAddress 192.168.100.14 -NoStorage
```

## SQL Server Issues

### Installation fails

**Solution:**
Check SQL Server installation logs:
```powershell
Get-Content "C:\Program Files\Microsoft SQL Server\150\Setup Bootstrap\Log\Summary.txt"
```

Common issues:
- .NET Framework not installed
- Service account permissions
- Disk space

### Always On cannot be enabled

**Error:** "The Windows Server Failover Clustering (WSFC) cluster could not be contacted"

**Solution:**
1. Verify cluster is running: `Get-Cluster`
2. Ensure SQL Server service account has cluster permissions
3. Restart SQL Server service:
```powershell
Restart-Service MSSQLSERVER
```

### AG creation fails

**Solution:**
1. Verify endpoints exist on all nodes:
```sql
SELECT name, state_desc FROM sys.endpoints WHERE type = 4
```

2. Ensure database is in FULL recovery:
```sql
ALTER DATABASE TestDB SET RECOVERY FULL
BACKUP DATABASE TestDB TO DISK = 'C:\SQLBackup\TestDB.bak'
BACKUP LOG TestDB TO DISK = 'C:\SQLBackup\TestDB.trn'
```

3. Check firewall for port 5022

### AG Listener creation fails

**Solution:**
1. Verify IP address is available (not in use)
2. Ensure cluster network is configured correctly:
```powershell
Get-ClusterNetwork
```

3. Check DNS can update for the listener name

## Kerberos Issues

### SPNs not registered

**Solution:**
```powershell
# List current SPNs
setspn -L LAB\sqlservice

# Manually register if needed
setspn -S MSSQLSvc/sql01.lab.local:1433 LAB\sqlservice
setspn -S MSSQLSvc/ag01-listener.lab.local:1433 LAB\sqlservice
```

### Authentication fails with "Login failed for user ''"

**Solution:**
1. Verify SPNs are registered (see above)
2. Ensure client is using FQDN, not IP address
3. Check Kerberos ticket:
```bash
# On Linux
klist

# On Windows
klist
```

4. Verify SQL Server is running under domain service account

### Java Kerberos connection fails

**Error:** `Cannot find key of appropriate type to decrypt AP REP`

**Solution:**
1. Ensure krb5.conf is correct
2. Verify JDBC driver supports Kerberos
3. Use correct JDK (OpenJDK 11+)
4. Check Java Kerberos configuration:
```bash
export KRB5_TRACE=/dev/stdout
java -Dsun.security.krb5.debug=true ...
```

## Network Issues

### VMs cannot reach internet

**Solution:**
```bash
# Restart libvirt network
virsh net-destroy virbr-lab
virsh net-start virbr-lab

# Check NAT is working
sudo iptables -t nat -L -n -v
```

### DNS resolution fails

**Solution:**
1. Verify DC DNS service is running
2. Check DNS forwarders on DC:
```powershell
Get-DnsServerForwarder
```

3. Test DNS:
```powershell
nslookup sql01.lab.local
```

## Performance Issues

### VMs running slowly

**Solution:**
1. Check host resource usage:
```bash
top
free -h
df -h
```

2. Reduce VM resources if needed in `terraform/environments/lab/variables.tf`

3. Use CPU pinning for better performance:
```xml
<vcpu placement='static' cpuset='0-3'>4</vcpu>
```

### SQL Server slow

**Solution:**
1. Check SQL Server configuration:
```sql
EXEC sp_configure 'max server memory'
```

2. Verify disk I/O is not bottleneck:
```sql
SELECT * FROM sys.dm_io_virtual_file_stats(NULL, NULL)
```

3. Consider using virtio drivers for better disk performance

## Ansible Playbook Failures

### Playbook stops in the middle

**Solution:**
Ansible is idempotent. Re-run the playbook:
```bash
ansible-playbook -i inventory/lab.yml playbooks/site.yml
```

### Skip to specific phase

Run individual playbook:
```bash
ansible-playbook -i inventory/lab.yml playbooks/05-install-sql-server.yml
```

## Getting Help

1. Check VM console output: `virsh console <vm-name>`
2. View libvirt logs: `sudo journalctl -u libvirtd`
3. Check Ansible verbose output: `ansible-playbook -vvv ...`
4. Review Windows Event Logs on VMs
5. SQL Server error logs: `C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\ERRORLOG`

## Useful Commands

```bash
# List all VMs
virsh list --all

# Start all VMs
for vm in dc01 sql01 sql02 sql03 app01; do virsh start $vm; done

# Get VM IP addresses
virsh net-dhcp-leases virbr-lab

# Reset a VM
virsh reset dc01

# Take VM snapshot
virsh snapshot-create-as dc01 "clean-state"

# Restore snapshot
virsh snapshot-revert dc01 "clean-state"
```
