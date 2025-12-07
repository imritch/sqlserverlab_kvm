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
echo "Note: SQL Server 2025 is the latest version."
echo "Download the evaluation installer, then use 'Download Media' option to get the ISO."
echo ""
echo "Manual steps:"
echo "  1. Visit https://www.microsoft.com/en-us/sql-server/sql-server-downloads"
echo "  2. Download SQL Server 2025 Developer Edition"
echo "  3. Run the installer and choose 'Download Media'"
echo "  4. Select 'ISO' format and download location"
echo "  5. Save the ISO as: $ISO_DIR/SQLServer2025-DEV-x64-ENU.iso"
echo ""
echo "Expected filename: SQLServer2025-DEV-x64-ENU.iso"
echo ""
read -p "Press Enter when you have downloaded SQL Server 2025 ISO..."

# Verify SQL Server ISO
if [ -f "$ISO_DIR/SQLServer2025-DEV-x64-ENU.iso" ]; then
    echo "✓ Found SQL Server 2025 ISO"
    ls -lh "$ISO_DIR/SQLServer2025-DEV-x64-ENU.iso"
else
    echo "✗ SQL Server 2025 ISO not found at: $ISO_DIR/SQLServer2025-DEV-x64-ENU.iso"
    echo "  Please ensure the file is named exactly: SQLServer2025-DEV-x64-ENU.iso"
fi

echo ""
echo "ISO Download Summary"
echo "===================="
ls -lh "$ISO_DIR"/*.iso 2>/dev/null || echo "No ISO files found"

echo ""
echo "Note: ISOs are excluded from git via .gitignore"
echo "Total size: $(du -sh "$ISO_DIR" | cut -f1)"
