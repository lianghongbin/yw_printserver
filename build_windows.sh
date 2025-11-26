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

# Check if GRF file exists
if [ ! -f "img/yw_logo_final.grf" ]; then
    echo "Error: img/yw_logo_final.grf not found"
    echo "Please ensure the GRF file exists before building"
    exit 1
fi

# Generate template_final.zpl if needed (using binary GRF injection)
if [ ! -f "template_final.zpl" ]; then
    echo "Generating template_final.zpl..."
    python3 << 'PYTHON_SCRIPT'
# Read template
with open("template.zpl", "r", encoding="utf-8") as f:
    template = f.read()

# Read GRF content (binary)
with open("img/yw_logo_final.grf", "rb") as f:
    grf_data = f.read()

# Split template to insert GRF binary data properly
parts = template.split("{{LOGO_GRF}}")
if len(parts) == 2:
    # Write template part 1, then GRF binary, then template part 2
    with open("template_final.zpl", "wb") as f:
        f.write(parts[0].encode("utf-8"))
        f.write(grf_data)  # Write GRF as binary
        f.write(parts[1].encode("utf-8"))
else:
    # Fallback: simple replacement (may not work for binary data)
    grf_str = grf_data.decode("latin-1", errors="ignore")
    final_template = template.replace("{{LOGO_GRF}}", grf_str)
    with open("template_final.zpl", "wb") as f:
        f.write(final_template.encode("latin-1", errors="ignore"))
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


