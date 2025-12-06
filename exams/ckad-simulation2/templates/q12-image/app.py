#!/usr/bin/env python3
"""Simple Galaxy App for CKAD exam"""

import http.server
import socketserver
import os

PORT = 8080

class GalaxyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        message = f"Galaxy App v1 - Running on port {PORT}\n"
        self.wfile.write(message.encode())

if __name__ == "__main__":
    print(f"Galaxy App starting on port {PORT}")
    with socketserver.TCPServer(("", PORT), GalaxyHandler) as httpd:
        httpd.serve_forever()
