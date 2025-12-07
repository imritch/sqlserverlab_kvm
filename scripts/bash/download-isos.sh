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
echo "IMPORTANT: SQL Server 2025 download process has changed!"
echo ""
echo "Microsoft now provides a bootstrap installer (SQL2025-SSEI-EntDev.exe)"
echo "instead of a direct ISO download."
echo ""
echo "You have TWO OPTIONS:"
echo ""
echo "OPTION 1 - Extract ISO using Wine (Recommended for Ubuntu):"
echo "  Run: ./scripts/bash/extract-sql-iso.sh"
echo "  This will use Wine to run the Windows installer and download the ISO"
echo ""
echo "OPTION 2 - Use Bootstrap Installer (No ISO needed):"
echo "  Download SQL2025-SSEI-EntDev.exe to isos/"
echo "  The Ansible playbook will handle installation directly"
echo "  Use: ansible/playbooks/05-install-sql-server-bootstrap.yml"
echo ""
echo "OPTION 3 - Manual extraction (if you have Windows access):"
echo "  1. Download SQL2025-SSEI-EntDev.exe on a Windows machine"
echo "  2. Run it and choose 'Download Media'"
echo "  3. Select 'ISO' format"
echo "  4. Transfer the ISO to: $ISO_DIR/SQLServer2025-DEV-x64-ENU.iso"
echo ""
read -p "Which option will you use? [1/2/3]: " sql_option

case $sql_option in
    1)
        echo "Run: ./scripts/bash/extract-sql-iso.sh"
        ;;
    2)
        echo "Make sure SQL2025-SSEI-EntDev.exe is in $ISO_DIR/"
        echo "Then use the bootstrap playbook during installation"
        ;;
    3)
        echo "Transfer the ISO when ready"
        ;;
    *)
        echo "No option selected. You can run this script again later."
        ;;
esac

# Verify SQL Server ISO or bootstrap
if [ -f "$ISO_DIR/SQLServer2025-DEV-x64-ENU.iso" ]; then
    echo "✓ Found SQL Server 2025 ISO"
    ls -lh "$ISO_DIR/SQLServer2025-DEV-x64-ENU.iso"
elif [ -f "$ISO_DIR/SQL2025-SSEI-EntDev.exe" ]; then
    echo "✓ Found SQL Server 2025 Bootstrap Installer"
    ls -lh "$ISO_DIR/SQL2025-SSEI-EntDev.exe"
    echo "  You'll use the bootstrap installation method"
else
    echo "✗ SQL Server 2025 media not found"
    echo "  Looking for either:"
    echo "    - $ISO_DIR/SQLServer2025-DEV-x64-ENU.iso (ISO method)"
    echo "    - $ISO_DIR/SQL2025-SSEI-EntDev.exe (Bootstrap method)"
fi

echo ""
echo "ISO Download Summary"
echo "===================="
ls -lh "$ISO_DIR"/*.iso 2>/dev/null || echo "No ISO files found"

echo ""
echo "Note: ISOs are excluded from git via .gitignore"
echo "Total size: $(du -sh "$ISO_DIR" | cut -f1)"
