#!/bin/bash
set -e

ISO_DIR="$(dirname "$0")/../../isos"
mkdir -p "$ISO_DIR"

echo "SQL Server Lab - ISO Download Script"
echo "====================================="
echo ""
echo "This script will help you download required ISOs:"
echo "  1. Windows Server 2022 Evaluation (180-day trial)"
echo "  2. SQL Server 2025 Developer Edition (Free)"
echo ""

# Windows Server 2022
echo "Windows Server 2022 Evaluation"
echo "-------------------------------"
echo "Download from: https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022"
echo ""
echo "Direct link (may change):"
echo "https://go.microsoft.com/fwlink/p/?LinkID=2195280"
echo ""
echo "Manual steps:"
echo "  1. Visit the evaluation center URL above"
echo "  2. Fill out the form (or use direct link)"
echo "  3. Download the ISO file"
echo "  4. Save it as: $ISO_DIR/windows-server-2022.iso"
echo ""
read -p "Press Enter when you have downloaded Windows Server 2022 ISO..."

# Verify Windows Server ISO
if [ -f "$ISO_DIR/windows-server-2022.iso" ]; then
    echo "✓ Found Windows Server 2022 ISO"
    ls -lh "$ISO_DIR/windows-server-2022.iso"
else
    echo "✗ Windows Server 2022 ISO not found at: $ISO_DIR/windows-server-2022.iso"
    echo "  Please download and place it there before continuing."
fi

echo ""
echo "SQL Server 2025 Developer Edition"
echo "----------------------------------"
echo "Download from: https://www.microsoft.com/en-us/sql-server/sql-server-downloads"
echo ""
echo "Download SQL2025-SSEI-EntDev.exe and place it in: $ISO_DIR/"
echo ""
echo "Steps:"
echo "  1. Visit https://www.microsoft.com/en-us/sql-server/sql-server-downloads"
echo "  2. Click 'Download now' under Developer edition"
echo "  3. Save the file as: $ISO_DIR/SQL2025-SSEI-EntDev.exe"
echo ""
echo "The Ansible playbook will use this installer to automatically install"
echo "SQL Server on all nodes using the config.ini (unattended installation)."
echo ""
read -p "Press Enter when you have downloaded SQL2025-SSEI-EntDev.exe..."

# Verify SQL Server installer
if [ -f "$ISO_DIR/SQL2025-SSEI-EntDev.exe" ]; then
    echo "✓ Found SQL Server 2025 Bootstrap Installer"
    ls -lh "$ISO_DIR/SQL2025-SSEI-EntDev.exe"
else
    echo "✗ SQL Server 2025 installer not found at: $ISO_DIR/SQL2025-SSEI-EntDev.exe"
    echo "  Please download and place it there."
fi

echo ""
echo "ISO Download Summary"
echo "===================="
ls -lh "$ISO_DIR"/*.iso 2>/dev/null || echo "No ISO files found"

echo ""
echo "Note: ISOs are excluded from git via .gitignore"
echo "Total size: $(du -sh "$ISO_DIR" | cut -f1)"
