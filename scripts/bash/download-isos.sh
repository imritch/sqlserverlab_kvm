#!/bin/bash
set -e

ISO_DIR="$(dirname "$0")/../../isos"
mkdir -p "$ISO_DIR"

echo "SQL Server Lab - ISO Download Script"
echo "====================================="
echo ""
echo "This script will help you download required ISOs:"
echo "  1. Windows Server 2022 Evaluation (180-day trial)"
echo "  2. SQL Server 2022 Developer Edition (Free)"
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
echo "SQL Server 2022 Developer Edition"
echo "----------------------------------"
echo "Download from: https://www.microsoft.com/en-us/sql-server/sql-server-downloads"
echo ""
echo "Direct link:"
echo "https://go.microsoft.com/fwlink/p/?linkid=2215158"
echo ""
echo "Alternative: Download the installer and extract the ISO:"
echo "  1. Download SQL Server 2022 Developer installer"
echo "  2. Run it and choose 'Download Media'"
echo "  3. Select 'ISO' and download location"
echo ""
echo "Or use curl to download directly:"
echo "  cd $ISO_DIR"
echo "  curl -L 'https://go.microsoft.com/fwlink/p/?linkid=2215158' -o SQLServer2022-DEV-x64-ENU.iso"
echo ""
read -p "Download SQL Server ISO now using curl? [y/N]: " download_sql

if [[ "$download_sql" =~ ^[Yy]$ ]]; then
    echo "Downloading SQL Server 2022 Developer Edition ISO..."
    cd "$ISO_DIR"
    curl -L 'https://go.microsoft.com/fwlink/p/?linkid=2215158' -o SQLServer2022-DEV-x64-ENU.iso
    echo "✓ SQL Server ISO downloaded"
else
    echo "Please download manually and save as: $ISO_DIR/SQLServer2022-DEV-x64-ENU.iso"
    read -p "Press Enter when done..."
fi

# Verify SQL Server ISO
if [ -f "$ISO_DIR/SQLServer2022-DEV-x64-ENU.iso" ]; then
    echo "✓ Found SQL Server 2022 ISO"
    ls -lh "$ISO_DIR/SQLServer2022-DEV-x64-ENU.iso"
else
    echo "✗ SQL Server 2022 ISO not found at: $ISO_DIR/SQLServer2022-DEV-x64-ENU.iso"
fi

echo ""
echo "ISO Download Summary"
echo "===================="
ls -lh "$ISO_DIR"/*.iso 2>/dev/null || echo "No ISO files found"

echo ""
echo "Note: ISOs are excluded from git via .gitignore"
echo "Total size: $(du -sh "$ISO_DIR" | cut -f1)"
