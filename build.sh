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

# Step 2: Inject logo.grf into template
echo "→ 2. Injecting GRF into template..."

# Use Python to safely replace placeholders (avoid sed special character issues)
.venv/bin/python3 << 'PYTHON_SCRIPT'
import re

# Read template
with open("template.zpl", "r", encoding="utf-8") as f:
    template = f.read()

# Read GRF content
with open("img/logo.grf", "r", encoding="utf-8") as f:
    logo_grf = f.read()

# Replace placeholder
final_template = template.replace("{{LOGO_GRF}}", logo_grf)

# Write final file
with open("template_final.zpl", "w", encoding="utf-8") as f:
    f.write(final_template)
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