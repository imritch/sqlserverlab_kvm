#!/bin/bash
set -e

echo "Installing SQL Server Lab Prerequisites..."

# Update package list
echo "[1/6] Updating package lists..."
sudo apt update

# Install KVM/QEMU and libvirt
echo "[2/6] Installing KVM/QEMU and libvirt..."
sudo apt install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virt-manager \
    libvirt-dev \
    libguestfs-tools \
    genisoimage \
    virtinst

# Add user to libvirt groups
echo "[3/6] Adding user to libvirt groups..."
sudo usermod -aG libvirt,kvm $USER

# Install Terraform
echo "[4/6] Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update
    sudo apt install -y terraform
else
    echo "Terraform already installed: $(terraform version | head -n1)"
fi

# Install Ansible
echo "[5/6] Installing Ansible..."
if ! command -v ansible &> /dev/null; then
    sudo apt install -y software-properties-common
    sudo add-apt-repository --yes --update ppa:ansible/ansible
    sudo apt install -y ansible
else
    echo "Ansible already installed: $(ansible --version | head -n1)"
fi

# Install Python dependencies for Ansible Windows support
echo "[6/6] Installing Python dependencies..."
sudo apt install -y python3-pip
pip3 install --user pywinrm

# Install Terraform libvirt provider dependencies
echo "Installing Terraform libvirt provider dependencies..."
go install github.com/dmacvicar/terraform-provider-libvirt@latest 2>/dev/null || echo "Note: Go not installed, will download provider via Terraform"

# Enable and start libvirtd
sudo systemctl enable libvirtd
sudo systemctl start libvirtd

# Verify KVM support
echo ""
echo "Verifying KVM support..."
if [ -e /dev/kvm ]; then
    echo "✓ KVM is supported"
else
    echo "✗ KVM is not supported - check BIOS virtualization settings"
fi

# Check virtualization
kvm-ok || echo "Note: kvm-ok check failed, but KVM may still work"

echo ""
echo "Installation complete!"
echo ""
echo "IMPORTANT: You may need to log out and back in for group changes to take effect."
echo ""
echo "Verify installation:"
echo "  virsh version"
echo "  terraform version"
echo "  ansible --version"
echo ""
echo "Next steps:"
echo "  1. Log out and log back in (for group membership)"
echo "  2. Run: ./scripts/bash/download-isos.sh"
echo "  3. Initialize Terraform: cd terraform/environments/lab && terraform init"
