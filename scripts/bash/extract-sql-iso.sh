#!/bin/bash
set -e

echo "SQL Server 2025 - ISO Extraction Script (Ubuntu)"
echo "=================================================="
echo ""
echo "This script helps you extract the SQL Server 2025 ISO using Wine"
echo ""

# Check if Wine is installed
if ! command -v wine &> /dev/null; then
    echo "Wine is not installed. Installing Wine..."
    sudo dpkg --add-architecture i386
    sudo apt update
    sudo apt install -y wine64 wine32 winetricks
else
    echo "✓ Wine is already installed"
fi

ISO_DIR="$(cd "$(dirname "$0")/../../isos" && pwd)"
DOWNLOAD_DIR="$HOME/Downloads"

echo ""
echo "Instructions:"
echo "============="
echo ""
echo "1. Place the SQL2025-SSEI-EntDev.exe file in: $DOWNLOAD_DIR"
echo ""
read -p "Press Enter when the file is ready..."

if [ ! -f "$DOWNLOAD_DIR/SQL2025-SSEI-EntDev.exe" ]; then
    echo "Error: SQL2025-SSEI-EntDev.exe not found in $DOWNLOAD_DIR"
    exit 1
fi

echo ""
echo "Running SQL Server setup to download ISO..."
echo "This will open a Windows installer GUI via Wine."
echo ""
echo "In the installer:"
echo "  1. Select 'Download Media'"
echo "  2. Choose 'ISO'"
echo "  3. Select download location: $ISO_DIR"
echo "  4. Click Download"
echo ""
read -p "Press Enter to launch the installer..."

cd "$DOWNLOAD_DIR"
wine SQL2025-SSEI-EntDev.exe

echo ""
echo "After the download completes, check for the ISO:"
ls -lh "$ISO_DIR"/*.iso 2>/dev/null || echo "No ISO files found yet"
echo ""
echo "Rename the downloaded ISO to: SQLServer2025-DEV-x64-ENU.iso"
