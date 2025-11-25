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

if [ ! -f img/yw_logo.grf ]; then
    echo "❌ Failed to generate yw_logo.grf (img/yw_logo.grf does not exist)"
    exit 1
fi

echo "✔ yw_logo.grf generated"

# Step 2: Inject logo GRF into template
echo "→ 2. Injecting GRF into template..."

# Read GRF content and inject into template
.venv/bin/python3 << 'PYTHON_SCRIPT'
# Read template
with open("template.zpl", "r", encoding="utf-8") as f:
    template = f.read()

# Read GRF content (binary)
with open("img/yw_logo_final.grf", "rb") as f:
    grf_data = f.read()

# GRF format: ~DGNAME,compressed_size,uncompressed_size,compressed_data
# The GRF file already contains the complete ~DG command with binary compressed data
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

echo "✔ template_final.zpl generated"

echo ""
echo "===== Build Complete ====="
echo "Final file → template_final.zpl"
echo ""

# Step 3: Check port 8023
echo ""
echo "Checking port 8023..."

PORT=8023
PID=$(lsof -ti:$PORT 2>/dev/null)

if [ -n "$PID" ]; then
    if [ "$1" = "--force" ] || [ "$1" = "-f" ]; then
        echo "⚠️  Port $PORT is occupied by process $PID"
        echo "→ Force closing process $PID..."
        kill $PID 2>/dev/null
        sleep 1
        # Verify port is released
        if lsof -ti:$PORT >/dev/null 2>&1; then
            echo "❌ Failed to close process on port $PORT"
            exit 1
        else
            echo "✔ Port $PORT is now available"
        fi
    else
        echo "⚠️  Port $PORT is already in use (PID: $PID)"
        echo "   To force close and start server, use: bash build.sh --force"
        echo "   Or manually close the process: kill $PID"
        exit 1
    fi
else
    echo "✔ Port $PORT is available"
fi

# Step 4: Start print service
echo ""
echo "Starting print service..."

# Set signal handling to ensure Ctrl+C is properly passed
trap 'exit 0' INT TERM

# Start server
.venv/bin/python3 print_server.py