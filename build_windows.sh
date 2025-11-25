#!/bin/bash
# Build script for Windows executable (run on macOS/Linux with Wine or on Windows)
# This script packages the print server into a Windows .exe file

echo "===== Building Windows Executable ====="
echo

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Install dependencies
echo "Installing dependencies..."
pip install -q --upgrade pip
pip install -q -r requirements.txt
pip install -q pyinstaller

# Generate logo.grf if needed
if [ ! -f "img/logo.grf" ]; then
    echo "Generating logo.grf..."
    python convert_logo.py
fi

# Generate template_final.zpl if needed
if [ ! -f "template_final.zpl" ]; then
    echo "Generating template_final.zpl..."
    python3 << 'PYTHON_SCRIPT'
import re
with open("template.zpl", "r", encoding="utf-8") as f:
    template = f.read()
with open("img/logo.grf", "r", encoding="utf-8") as f:
    logo_grf = f.read()
final_template = template.replace("{{LOGO_GRF}}", logo_grf)
with open("template_final.zpl", "w", encoding="utf-8") as f:
    f.write(final_template)
PYTHON_SCRIPT
fi

# Build executable with PyInstaller
echo
echo "Building executable..."
pyinstaller --clean --noconfirm print_server.spec

if [ -f "dist/print_server.exe" ]; then
    echo
    echo "===== Build Complete ====="
    echo "Executable: dist/print_server.exe"
    echo
    echo "To run: dist/print_server.exe"
else
    echo
    echo "===== Build Failed ====="
    exit 1
fi

