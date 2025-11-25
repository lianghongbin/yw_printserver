#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import http.server
import socketserver
import json
import socket
import traceback

PRINTER_IP = "192.168.110.135"
PRINTER_PORT = 9100
LISTEN_PORT = 8023

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, fmt, *args):
        return  # 禁止默认 noisy 日志

    def do_POST(self):

        if self.path != "/api/printMessages/printExternalPdaLabel":
            self.send_response(404)
            self.end_headers()
            return

        try:
            # 读取 body
            length = int(self.headers.get("Content-Length", 0))
            body = self.rfile.read(length).decode("utf-8", "ignore")
            data = json.loads(body)

            # 获取要打印的内容
            item = data.get("params", [{}])[0]
            label_text = (
                item.get("barCode") or
                item.get("barCodeName") or
                item.get("content") or
                ""
            )

            if not label_text:
                raise Exception("未找到可打印字段")

            # 组装最简单的 ZPL
            zpl = f"^XA^FO20,20^A0N,30,30^FD{label_text}^FS^XZ"

            # 发送到标签打印机
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(8)
            sock.connect((PRINTER_IP, PRINTER_PORT))
            sock.sendall(zpl.encode())
            sock.close()

            # 返回 PDA 需要的 JSON
            self.send_response(200)
            self.send_header("Content-Type", "application/json; charset=UTF-8")
            self.end_headers()
            self.wfile.write(b'{"code":0,"success":true}')

            print(f"\n📨 来自 PDA: {self.client_address[0]}")
            print(f"📦 打印内容: {label_text}")
            print(f"➡ 已转发到打印机 {PRINTER_IP}:{PRINTER_PORT}")

        except Exception as e:
            print("❌ 错误:", e)
            traceback.print_exc()
            self.send_response(500)
            self.end_headers()

if __name__ == "__main__":
    print(f"\n🚀 PDA 打印代理已启动")
    print(f"监听 HTTP : {LISTEN_PORT}")
    print(f"打印机    : {PRINTER_IP}:{PRINTER_PORT}\n")

    server = socketserver.ThreadingTCPServer(("", LISTEN_PORT), Handler)
    server.serve_forever()
