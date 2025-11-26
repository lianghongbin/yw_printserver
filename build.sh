#!/bin/bash

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "❌ Error: Virtual environment not found, please run: python3 -m venv .venv"
    exit 1
fi

# Step 1: Build template
.venv/bin/python3 build_template.py

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

# Start server and wait for it to exit
# Ctrl+C will be passed to Python process, which handles graceful shutdown
.venv/bin/python3 print_server.py