#!/usr/bin/env python3
"""
Genesis Speech Tab - Local Server & TTS Audio Cache
Serves web app and caches high-definition Google Voices offline.
"""

import os
import sys
import urllib.request
import urllib.parse
import hashlib
from http.server import HTTPServer, SimpleHTTPRequestHandler

PORT = 8888
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CACHE_DIR = os.path.join(BASE_DIR, "assets", "audio_cache")

os.makedirs(CACHE_DIR, exist_ok=True)

class AacRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def do_GET(self):
        # Serve TTS proxy endpoint: /tts?q=...&tl=...
        if self.path.startswith("/tts?"):
            parsed = urllib.parse.urlparse(self.path)
            params = urllib.parse.parse_qs(parsed.query)
            q = params.get("q", [""])[0].strip()
            tl = params.get("tl", ["en"])[0].strip()

            if not q:
                self.send_error(400, "Missing 'q' query parameter")
                return

            # Hash text and language for caching on disk
            cache_key = hashlib.md5(f"{tl}_{q}".encode("utf-8")).hexdigest()
            cache_file = os.path.join(CACHE_DIR, f"{cache_key}.mp3")

            if not os.path.exists(cache_file):
                try:
                    google_url = f"https://translate.google.com/translate_tts?ie=UTF-8&q={urllib.parse.quote(q)}&tl={urllib.parse.quote(tl)}&client=tw-ob"
                    req = urllib.request.Request(google_url, headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"})
                    with urllib.request.urlopen(req, timeout=5) as response:
                        audio_data = response.read()
                        with open(cache_file, "wb") as f:
                            f.write(audio_data)
                except Exception as e:
                    print(f"[!] Error fetching Google TTS: {e}")
                    self.send_error(502, f"TTS service unavailable: {e}")
                    return

            # Stream cached MP3 file
            try:
                with open(cache_file, "rb") as f:
                    data = f.read()
                    self.send_response(200)
                    self.send_header("Content-Type", "audio/mpeg")
                    self.send_header("Content-Length", str(len(data)))
                    self.send_header("Access-Control-Allow-Origin", "*")
                    self.send_header("Cache-Control", "public, max-age=31536000")
                    self.end_headers()
                    self.wfile.write(data)
            except Exception as e:
                self.send_error(500, f"Error reading cached audio: {e}")
            return

        # Default static file serving (index.html at root)
        if self.path == "/" or self.path == "":
            self.path = "/index.html"

        return super().do_GET()

def run():
    server_address = ("0.0.0.0", PORT)
    httpd = HTTPServer(server_address, AacRequestHandler)
    print(f"[*] Genesis Speech Tab running on http://localhost:{PORT}")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Server stopped.")

if __name__ == "__main__":
    run()
