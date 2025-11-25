#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import http.server
import json
import socket
import signal
import sys
import threading
from datetime import datetime

PRINTER_PORT = 9100
LISTEN_PORT = 8023

# Printer mapping: printerId -> IP address
PRINTER_MAP = {
    "PT135": "192.168.110.135",
    "PT136": "192.168.110.136",
}

TEMPLATE_FILE = "template_final.zpl"

def load_template():
    """Load template file, support both development and packaged executable"""
    import os
    import sys
    
    # If running as PyInstaller bundle, get the base path
    if getattr(sys, 'frozen', False):
        base_path = sys._MEIPASS
    else:
        base_path = os.path.dirname(os.path.abspath(__file__))
    
    template_path = os.path.join(base_path, TEMPLATE_FILE)
    with open(template_path, "r", encoding="utf-8") as f:
        return f.read()

def render(tpl, data):
    for k, v in data.items():
        tpl = tpl.replace("{{" + k + "}}", str(v))
    return tpl

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        return  # Disable default HTTP log output

    def do_POST(self):

        if self.path != "/api/printMessages/printExternalPdaLabel":
            self.send_response(404)
            self.end_headers()
            return

        try:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"\n[{timestamp}] ===== New Print Request =====")
            
            # Step 1: Read request data
            length = int(self.headers.get("Content-Length", 0))
            print(f"[{timestamp}] [STEP 1] Received request, Content-Length: {length}")
            
            raw = self.rfile.read(length).decode("utf-8", errors="ignore")
            print(f"[{timestamp}] [STEP 1] Raw data: {raw[:200]}...")
            
            data = json.loads(raw)
            print(f"[{timestamp}] [STEP 1] JSON parsed successfully")

            # Step 2: Get printerId
            printer_id = data.get("printerId", "")
            print(f"[{timestamp}] [STEP 2] printerId: '{printer_id}'")
            
            if not printer_id:
                raise ValueError("printerId parameter not found")

            # Step 3: Get printer IP
            printer_ip = PRINTER_MAP.get(printer_id)
            print(f"[{timestamp}] [STEP 3] Printer IP lookup: {printer_id} → {printer_ip}")
            
            if not printer_ip:
                raise ValueError(f"Unknown printer ID: {printer_id}, supported printers: {list(PRINTER_MAP.keys())}")

            # Step 4: Parse parameters
            p = data["params"][0]
            print(f"[{timestamp}] [STEP 4] Parameters extracted:")
            print(f"  - from: {p.get('from', '')}")
            print(f"  - to: {p.get('to', '')}")
            print(f"  - barCode: {p.get('barCode', '')}")
            print(f"  - barCodeName: {p.get('barCodeName', '')}")
            print(f"  - pieces: {p.get('pieces', '')}")
            print(f"  - weight: {p.get('weight', '')}")

            # Step 5: Generate template variables
            now = datetime.now()
            footer_time = now.strftime("%Y.%m.%d %H:%M:%S")

            zpl_vars = {
                "from": p.get("from", ""),
                "to": p.get("to", ""),
                "barcode": p.get("barCode", "") or p.get("barCodeName", ""),
                "pieces": p.get("pieces", ""),
                "weight": p.get("weight", ""),
                "of": "of",
                "footer_warehouse": p.get("to", ""),
                "footer_time": footer_time
            }
            print(f"[{timestamp}] [STEP 5] Template variables prepared:")
            for key, value in zpl_vars.items():
                print(f"  - {key}: {value}")

            # Step 6: Load and render template
            print(f"[{timestamp}] [STEP 6] Loading template from: {TEMPLATE_FILE}")
            tpl = load_template()
            print(f"[{timestamp}] [STEP 6] Template loaded, size: {len(tpl)} bytes")
            
            final_zpl = render(tpl, zpl_vars)
            print(f"[{timestamp}] [STEP 6] ZPL generated, size: {len(final_zpl)} bytes")
            print(f"[{timestamp}] [STEP 6] ZPL preview (first 200 chars): {final_zpl[:200]}")
            print(f"[{timestamp}] [STEP 6] ZPL preview (last 100 chars): ...{final_zpl[-100:]}")

            # Step 7: Connect to printer
            print(f"[{timestamp}] [STEP 7] Connecting to printer {printer_id} at {printer_ip}:{PRINTER_PORT}")
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.settimeout(5)
            
            try:
                s.connect((printer_ip, PRINTER_PORT))
                print(f"[{timestamp}] [STEP 7] ✓ Connection established")
            except socket.timeout:
                print(f"[{timestamp}] [STEP 7] ✗ Connection timeout (5s)")
                raise Exception(f"Connection to printer {printer_ip}:{PRINTER_PORT} timed out")
            except socket.error as e:
                print(f"[{timestamp}] [STEP 7] ✗ Connection failed: {e}")
                raise Exception(f"Failed to connect to printer {printer_ip}:{PRINTER_PORT}: {e}")

            # Step 8: Send ZPL data
            zpl_bytes = final_zpl.encode()
            print(f"[{timestamp}] [STEP 8] Sending ZPL data ({len(zpl_bytes)} bytes)...")
            try:
                s.sendall(zpl_bytes)
                print(f"[{timestamp}] [STEP 8] ✓ Data sent successfully ({len(zpl_bytes)} bytes)")
            except socket.error as e:
                print(f"[{timestamp}] [STEP 8] ✗ Send failed: {e}")
                raise Exception(f"Failed to send data to printer: {e}")
            
            s.close()
            print(f"[{timestamp}] [STEP 8] Socket closed")

            # Step 9: Success
            barcode = p.get("barCode", "") or p.get("barCodeName", "")
            print(f"[{timestamp}] [SUCCESS] Print job completed")
            print(f"[{timestamp}] Summary: {printer_id:8s} | {barcode:30s} | {p.get('from', '')} → {p.get('to', '')}")
            print(f"[{timestamp}] ===== End Print Request =====\n")

            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=UTF-8")
            self.end_headers()
            self.wfile.write(b'{"code":0,"msg":"OK","success":true}')

        except ValueError as e:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{timestamp}] [ERROR] ValueError: {e}")
            print(f"[{timestamp}] ===== End Print Request (Error) =====\n")
            self.send_response(400)
            self.send_header("Content-Type", "application/json; charset=UTF-8")
            self.end_headers()
            self.wfile.write(f'{{"code":400,"msg":"{str(e)}","success":false}}'.encode())
        except Exception as e:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            print(f"[{timestamp}] [ERROR] Print failed: {type(e).__name__}: {e}")
            import traceback
            print(f"[{timestamp}] [ERROR] Traceback:")
            traceback.print_exc()
            print(f"[{timestamp}] ===== End Print Request (Error) =====\n")
            self.send_response(500)
            self.send_header("Content-Type", "application/json; charset=UTF-8")
            self.end_headers()
            self.wfile.write(f'{{"code":500,"msg":"Print failed: {str(e)}","success":false}}'.encode())

# Global server variable for signal handling
server = None

def get_local_ip():
    """Get local network IP address"""
    try:
        # Create a UDP socket (does not actually send data)
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        # Connect to external address (does not actually establish connection)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        # If the above method fails, try to get IP from hostname
        try:
            hostname = socket.gethostname()
            ip = socket.gethostbyname(hostname)
            # Filter out localhost
            if ip != "127.0.0.1":
                return ip
        except Exception:
            pass
        # If all methods fail, return localhost
        return "127.0.0.1"

def signal_handler(sig, frame):
    """Handle Ctrl+C signal, gracefully shutdown server"""
    print("\n")
    print("-" * 60)
    print("  Shutting down server...")
    if server:
        # shutdown() must be called from another thread to make serve_forever() exit immediately
        def shutdown():
            server.shutdown()
            server.server_close()
        threading.Thread(target=shutdown, daemon=True).start()
        # Wait for shutdown to complete
        import time
        time.sleep(0.3)
    print("  Server stopped")
    print("=" * 60)
    sys.exit(0)

# Register signal handlers
signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGTERM, signal_handler)

# Get local IP
local_ip = get_local_ip()

print("=" * 60)
print("  Print Server v1.0")
print("=" * 60)
print(f"  Server IP    : {local_ip}")
print(f"  Listen Port  : {LISTEN_PORT}")
print(f"  Status       : Running")
print("-" * 60)
print("  Available Printers:")
for printer_id, printer_ip in PRINTER_MAP.items():
    print(f"    {printer_id:8s} → {printer_ip}")
print("-" * 60)
print("  Press Ctrl+C to stop")
print("=" * 60)
print()

try:
    server = http.server.HTTPServer(("", LISTEN_PORT), Handler)
    server.serve_forever()
except (KeyboardInterrupt, SystemExit):
    # Signal handler has already handled shutdown, just ensure cleanup here
    pass
except Exception as e:
    print(f"\n[ERROR] Server error: {e}")
    import traceback
    traceback.print_exc()
    if server:
        try:
            server.shutdown()
            server.server_close()
        except:
            pass
    sys.exit(1)