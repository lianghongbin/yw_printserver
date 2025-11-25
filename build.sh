#!/bin/bash

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Error: Virtual environment not found, please run: python3 -m venv .venv"
    exit 1
fi

echo "===== Building ZPL Template ====="

# Step 1: Generate logo.grf
echo "→ 1. Converting logo PNG to GRF..."
.venv/bin/python3 convert_logo.py

if [ ! -f img/logo.grf ]; then
    echo "❌ Failed to generate logo.grf (img/logo.grf does not exist)"
    exit 1
fi

echo "✔ logo.grf generated"

# Step 2: Copy template to final (no logo injection needed)
echo "→ 2. Preparing template..."

# Simply copy template.zpl to template_final.zpl (no logo replacement needed)
.venv/bin/python3 << 'PYTHON_SCRIPT'
# Read template
with open("template.zpl", "r", encoding="utf-8") as f:
    template = f.read()

# Write final file (no logo replacement)
with open("template_final.zpl", "w", encoding="utf-8") as f:
    f.write(template)
PYTHON_SCRIPT

echo "✔ template_final.zpl generated"

echo ""
echo "===== Build Complete ====="
echo "Final file → template_final.zpl"
echo ""

# Step 3: Start print service
echo ""
echo "Starting print service..."

# Set signal handling to ensure Ctrl+C is properly passed
trap 'exit 0' INT TERM

# Start server
.venv/bin/python3 print_server.py