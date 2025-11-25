#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Convert ./img/yw_logo.png to Zebra GRF font file

import sys
import re

try:
    from PIL import Image
except ImportError:
    print("❌ Error: Missing Pillow library, please run: pip3 install --user Pillow")
    sys.exit(1)

try:
    import zpl
except ImportError:
    print("❌ Error: Missing zpl library, please run: pip3 install --user zpl")
    sys.exit(1)

INPUT = "img/yw_logo.png"
OUTPUT = "img/logo.grf"

try:
    img = Image.open(INPUT).convert("1")
    
    # Use zpl library to generate ZPL code containing graphics
    label = zpl.Label(100, 100)
    label.write_graphic(img, 50)  # Width 50mm
    
    zpl_code = label.dumpZPL()
    
    # Extract GFA (Graphic Field ASCII) data from ZPL code
    # Format: ^GFA,bytes_total,bytes_per_row,bytes_compressed,data
    match = re.search(r'\^GFA,(\d+),(\d+),(\d+),(.+)', zpl_code)
    if match:
        bytes_total = match.group(1)
        bytes_per_row = match.group(2)
        bytes_compressed = match.group(3)
        data = match.group(4)
        
        # Generate GRF format: ~DGLOGO,bytes_total,bytes_per_row,bytes_compressed,data
        grf_content = f"~DGLOGO,{bytes_total},{bytes_per_row},{bytes_compressed},{data}"
        
        with open(OUTPUT, "w") as f:
            f.write(grf_content)
        
        print("✔ logo.grf generated →", OUTPUT)
    else:
        print("❌ Error: Unable to extract graphic data from ZPL code")
        print("ZPL code preview:", zpl_code[:200])
        sys.exit(1)
        
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)