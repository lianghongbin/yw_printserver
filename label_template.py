#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Shipping Label 打印模板
根据图片布局生成完整的 shipping label ZPL 代码
标签尺寸：4x6 英寸 (812x1218 点 @ 203 DPI)
"""

from datetime import datetime


def generate_shipping_label_zpl(item):
    """
    根据图片布局生成完整的 shipping label ZPL 代码
    
    Args:
        item: 包含打印数据的字典，字段包括：
            - barCode 或 barCodeName: 条形码/追踪号
            - from: 发件地代码
            - to: 收件地代码
            - pieces: 件数
            - weight: 重量
            - printSign: 笼号（CageNo）
    
    Returns:
        str: 完整的 ZPL 命令字符串
    """
    # 提取字段
    bar_code = item.get("barCode") or item.get("barCodeName") or ""
    from_code = item.get("from", "")
    to_code = item.get("to", "")
    pieces = item.get("pieces", "")
    weight = item.get("weight", "0kg")
    cage_no = item.get("printSign", "")  # printSign 作为 CageNo
    
    # 生成当前日期时间
    now = datetime.now()
    date_time = now.strftime("%Y.%m.%d %H:%M:%S")
    
    # 开始 ZPL 命令
    zpl = "^XA"
    
    # 设置标签大小：4x6 英寸
    zpl += "^LL1218"  # 标签长度（高度）
    zpl += "^PW812"   # 标签宽度
    
    # 1. 左上角：YANWEN Express Logo
    zpl += "^FO20,20^A0N,40,40^FDYANWEN^FS"
    zpl += "^FO20,60^A0N,28,28^FDExpress^FS"
    
    # 2. 右上角：Transit（大字体，加粗）
    zpl += "^FO550,20^A1N,60,60^FDTransit^FS"
    
    # 第一条分隔线（在 Logo 和 From/To 之间，Y=90）
    zpl += "^FO10,90^GB792,2,2^FS"
    
    # 3. From: LAX01（左侧，大字体）
    zpl += "^FO20,105^A0N,32,32^FDFrom:^FS"
    zpl += "^FO20,140^A1N,50,50^FD" + from_code + "^FS"
    
    # 4. To: DFW01（右侧，大字体）
    zpl += "^FO450,105^A0N,32,32^FDTo:^FS"
    zpl += "^FO450,140^A1N,50,50^FD" + to_code + "^FS"
    
    # 第二条分隔线（在 From/To 和条形码之间，Y=195）
    zpl += "^FO10,195^GB792,2,2^FS"
    
    # 5. 条形码（大尺寸，几乎占满宽度）
    # Code 128 条形码，高度 120，显示文本在下方，宽度因子 3
    zpl += "^FO20,210^BY3,3,120^BCN,120,Y,N,N^FD" + bar_code + "^FS"
    
    # 6. 追踪号（条形码下方，居中）
    zpl += "^FO20,340^A0N,32,32^FD" + bar_code + "^FS"
    
    # 第三条分隔线（在条形码和 pieces/weight 之间，Y=380）
    zpl += "^FO10,380^GB792,2,2^FS"
    
    # 7. pieces: 11（左下，冒号后无空格）
    zpl += "^FO20,400^A0N,30,30^FDpieces: " + str(pieces) + "^FS"
    
    # 8. weight: 0kg（右下，冒号后无空格）
    zpl += "^FO450,400^A0N,30,30^FDweight: " + str(weight) + "^FS"
    
    # 第四条分隔线（在 pieces/weight 和 CageNo 之间，Y=440）
    zpl += "^FO10,440^GB792,2,2^FS"
    
    # 9. CageNo: LAX-A-001（左侧，在 pieces 下方，使用 printSign 的值）
    if cage_no:
        zpl += "^FO20,470^A0N,28,28^FDCageNo: " + cage_no + "^FS"
    
    # 10. 日期时间（底部右侧，与 CageNo 同一行）
    zpl += "^FO450,470^A0N,28,28^FD" + date_time + "^FS"
    
    # 结束 ZPL 命令
    zpl += "^XZ"
    
    return zpl


