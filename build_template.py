#!/usr/bin/env python3
"""
Build ZPL template by injecting GRF logo into template.zpl
"""

import sys
import os


def build_template():
    """Inject GRF logo into template and generate template_final.zpl"""
    
    # Check if GRF file exists
    grf_path = "img/yw_logo_final.grf"
    if not os.path.exists(grf_path):
        print(f"❌ Error: {grf_path} not found")
        print("   Please ensure the GRF file exists before building")
        sys.exit(1)
    
    print(f"✔ GRF file found: {grf_path}")
    
    # Read template
    print("→ Reading template.zpl...")
    try:
        with open("template.zpl", "r", encoding="utf-8") as f:
            template = f.read()
    except FileNotFoundError:
        print("❌ Error: template.zpl not found")
        sys.exit(1)
    
    # Read GRF content (binary)
    print("→ Reading GRF file...")
    with open(grf_path, "rb") as f:
        grf_data = f.read()
    
    # Inject GRF into template
    print("→ Injecting GRF into template...")
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
    
    print("✔ template_final.zpl generated")


if __name__ == "__main__":
    print("===== Building ZPL Template =====")
    build_template()
    print("")
    print("===== Build Complete =====")
    print("Final file → template_final.zpl")
    print("")

