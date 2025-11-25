#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from PIL import Image
import os

# 输入 PNG
INPUT = "img/yw_logo.png"
# 输出 GRF
OUTPUT = "img/yw_logo.grf"

# Zebra 打印机默认 203dpi = 8 dots/mm
DPI = 203


def convert_png_to_grf(png_path, grf_path):
    img = Image.open(png_path).convert("1")  # 转为黑白 1bit
    width, height = img.size

    # 每行字节数：每 8 像素 = 1 字节
    bytes_per_row = (width + 7) // 8
    total_bytes = bytes_per_row * height

    print(f"Logo 尺寸：{width}x{height} px")
    print(f"每行字节：{bytes_per_row}, 总字节：{total_bytes}")

    # 生成 hex 流
    hex_rows = []
    pixels = img.load()

    for y in range(height):
        row_bytes = []
        for x in range(0, width, 8):
            byte = 0
            for bit in range(8):
                px = pixels[x + bit, y] if x + bit < width else 255
                if px == 0:          # 黑色点 = 1
                    byte |= (1 << (7 - bit))
            row_bytes.append(f"{byte:02X}")
        hex_rows.append("".join(row_bytes))

    with open(grf_path, "w", newline="\n") as f:
        f.write(f"~DGR:YWLOGO.GRF,{total_bytes},{bytes_per_row},\n")
        f.write("".join(hex_rows))

    print(f"✔ 成功生成 GRF：{grf_path}")


if __name__ == "__main__":
    convert_png_to_grf(INPUT, OUTPUT)