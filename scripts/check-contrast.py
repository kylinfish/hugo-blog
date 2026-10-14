#!/usr/bin/env python3
"""WCAG contrast check for every color scheme in themes/terminal/data/colorschemes.json.

Text tokens must reach 4.5:1 on the page background; accents used as powerline
segment backgrounds must reach 3:1 against --on-accent (bold UI text)."""
import json, pathlib, sys

TEXT = ["fg", "fg-hi", "fg-body", "muted", "blue", "cyan", "green", "yellow", "purple"]
SEGMENTS = ["blue", "purple", "green", "yellow"]

def lum(hex_):
    rgb = [int(hex_[i:i + 2], 16) / 255 for i in (1, 3, 5)]
    lin = [c / 12.92 if c <= 0.03928 else ((c + 0.055) / 1.055) ** 2.4 for c in rgb]
    return 0.2126 * lin[0] + 0.7152 * lin[1] + 0.0722 * lin[2]

def ratio(a, b):
    hi, lo = sorted((lum(a), lum(b)), reverse=True)
    return (hi + 0.05) / (lo + 0.05)

path = pathlib.Path(__file__).resolve().parent.parent / "themes/terminal/data/colorschemes.json"
fails = 0
for s in json.loads(path.read_text())["schemes"]:
    c = s["colors"]
    for k in TEXT:
        r = ratio(c[k], c["bg"])
        if r < 4.5:
            fails += 1
            print(f"  FAIL {s['id']}: --{k} {c[k]} on --bg {c['bg']} = {r:.2f} (< 4.5)")
    for k in SEGMENTS:
        r = ratio(c["on-accent"], c[k])
        if r < 3:
            fails += 1
            print(f"  FAIL {s['id']}: --on-accent on --{k} {c[k]} = {r:.2f} (< 3)")
print("contrast ok" if not fails else f"{fails} contrast failures")
sys.exit(1 if fails else 0)
