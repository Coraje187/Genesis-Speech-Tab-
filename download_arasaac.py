#!/usr/bin/env python3
"""
ARASAAC Symbol Downloader Script
Downloads core AAC pictograms from the free ARASAAC API (Creative Commons CC BY-NC-SA).
Saves them directly into the assets folder for 100% offline usage on budget tablets.
"""

import os
import urllib.request
import json

BASE_URL = "https://api.arasaac.org/api/pictograms"
ASSETS_DIR = os.path.join(os.path.dirname(__file__), "assets", "symbols")

# Core words to fetch pictograms for
CORE_WORDS = [
    "i", "you", "want", "like", "go", "stop", "help", "eat", "drink",
    "see", "play", "more", "finished", "good", "bad", "happy", "tired",
    "apple", "water", "juice", "cracker", "tablet", "toilet", "please",
    "thank you", "yes", "no"
]

def main():
    os.makedirs(ASSETS_DIR, exist_ok=True)
    print(f"[*] Downloading core ARASAAC symbols to: {ASSETS_DIR}")

    for word in CORE_WORDS:
        try:
            # 1. Search ARASAAC API for best matching pictogram ID in English
            search_url = f"{BASE_URL}/en/bestsearch/{urllib.parse.quote(word)}"
            req = urllib.request.Request(search_url, headers={'User-Agent': 'OpenAAC/1.0'})
            
            with urllib.request.urlopen(req) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                if not data:
                    print(f"[-] No symbol found for: {word}")
                    continue
                
                picto_id = data[0]['_id']
                
            # 2. Download the PNG image (500px resolution)
            img_url = f"{BASE_URL}/{picto_id}?download=false"
            out_path = os.path.join(ASSETS_DIR, f"{word.replace(' ', '_')}.png")
            
            urllib.request.urlretrieve(img_url, out_path)
            print(f"[+] Downloaded: {word} -> {out_path} (ID: {picto_id})")

        except Exception as e:
            print(f"[!] Error downloading {word}: {e}")

    print("\n[✓] Done! All symbols cached locally for offline tablet execution.")

if __name__ == "__main__":
    main()
