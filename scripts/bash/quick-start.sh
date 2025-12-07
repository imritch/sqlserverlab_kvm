#!/bin/bash
set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       SQL Server Lab Environment - Quick Start Script         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_prerequisites() {
    echo "Checking prerequisites..."
    local missing=0

    # Check for required commands
    for cmd in virsh terraform ansible; do
        if ! command -v $cmd &> /dev/null; then
            echo -e "${RED}✗${NC} $cmd is not installed"
            missing=1
        else
            echo -e "${GREEN}✓${NC} $cmd is installed"
        fi
    done

    # Check for ISOs
    if [ ! -f "$PROJECT_ROOT/isos/windows-server-2022.iso" ]; then
        echo -e "${RED}✗${NC} Windows Server 2022 ISO not found"
        missing=1
    else
        echo -e "${GREEN}✓${NC} Windows Server 2022 ISO found"
    fi

    if [ ! -f "$PROJECT_ROOT/isos/SQLServer2022-DEV-x64-ENU.iso" ]; then
        echo -e "${RED}✗${NC} SQL Server 2022 ISO not found"
        missing=1
    else
        echo -e "${GREEN}✓${NC} SQL Server 2022 ISO found"
    fi

    if [ $missing -eq 1 ]; then
        echo ""
        echo -e "${RED}Prerequisites missing!${NC}"
        echo "Run: ./scripts/bash/install-prerequisites.sh"
        echo "Run: ./scripts/bash/download-isos.sh"
        exit 1
    fi

    echo -e "${GREEN}All prerequisites met!${NC}"
    echo ""
}

show_menu() {
    echo "What would you like to do?"
    echo ""
    echo "  1) Deploy infrastructure (Terraform)"
    echo "  2) Configure environment (Ansible)"
    echo "  3) Deploy everything (Terraform + Ansible)"
    echo "  4) Verify deployment"
    echo "  5) Start all VMs"
    echo "  6) Stop all VMs"
    echo "  7) Show VM status"
    echo "  8) Destroy everything"
    echo "  9) Exit"
    echo ""
    read -p "Enter your choice [1-9]: " choice

    case $choice in
        1) deploy_terraform ;;
        2) deploy_ansible ;;
        3) deploy_all ;;
        4) verify_deployment ;;
        5) start_vms ;;
        6) stop_vms ;;
        7) show_status ;;
        8) destroy_all ;;
        9) exit 0 ;;
        *) echo "Invalid choice"; show_menu ;;
    esac
}

deploy_terraform() {
    echo ""
    echo "Deploying infrastructure with Terraform..."
    cd "$PROJECT_ROOT/terraform/environments/lab"

    terraform init
    terraform plan

    read -p "Apply this plan? [y/N]: " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        terraform apply
    fi

    cd "$PROJECT_ROOT"
    echo ""
    echo -e "${GREEN}Infrastructure deployment complete!${NC}"
    echo ""
}

deploy_ansible() {
    echo ""
    echo "Configuring environment with Ansible..."
    echo "This will take 60-90 minutes..."
    cd "$PROJECT_ROOT/ansible"

    ansible-playbook -i inventory/lab.yml playbooks/site.yml

    cd "$PROJECT_ROOT"
    echo ""
    echo -e "${GREEN}Configuration complete!${NC}"
    echo ""
}

deploy_all() {
    deploy_terraform

    echo "Waiting 5 minutes for VMs to fully boot..."
    sleep 300

    deploy_ansible
    verify_deployment
}

verify_deployment() {
    echo ""
    echo "Verifying deployment..."
    cd "$PROJECT_ROOT/ansible"

    ansible-playbook -i inventory/lab.yml playbooks/09-verify-deployment.yml

    cd "$PROJECT_ROOT"
    echo ""
}

start_vms() {
    echo ""
    echo "Starting all VMs..."
    for vm in dc01 sql01 sql02 sql03 app01; do
        echo "Starting $vm..."
        virsh start $vm 2>/dev/null || echo "$vm already running"
    done
    echo -e "${GREEN}All VMs started!${NC}"
    echo ""
    show_status
}

stop_vms() {
    echo ""
    echo "Stopping all VMs..."
    for vm in sql03 sql02 sql01 app01 dc01; do
        echo "Stopping $vm..."
        virsh shutdown $vm 2>/dev/null || echo "$vm not running"
    done
    echo -e "${GREEN}All VMs stopped!${NC}"
    echo ""
}

show_status() {
    echo ""
    echo "VM Status:"
    echo "=========="
    virsh list --all | grep -E 'sql|dc01|app01' || echo "No VMs found"
    echo ""

    echo "Network Status:"
    echo "==============="
    virsh net-list | grep virbr-lab || echo "Lab network not found"
    echo ""
}

destroy_all() {
    echo ""
    echo -e "${RED}WARNING: This will destroy all VMs and data!${NC}"
    read -p "Are you sure? Type 'yes' to confirm: " confirm

    if [ "$confirm" != "yes" ]; then
        echo "Cancelled."
        return
    fi

    echo "Destroying infrastructure..."
    cd "$PROJECT_ROOT/terraform/environments/lab"
    terraform destroy
    cd "$PROJECT_ROOT"

    echo -e "${GREEN}Infrastructure destroyed!${NC}"
    echo ""
}

# Main script
check_prerequisites
show_menu
