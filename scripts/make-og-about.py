#!/usr/bin/env python3
"""Render the about page's share image (static/img/og/about.png, 1200x630).

Reads the avatar (config.toml params.avatar), tagline / role / status
(data/profile.yaml) and the default dark scheme's colors
(themes/terminal/data/colorschemes.json), so re-run it whenever those change:
    python3 scripts/make-og-about.py
"""
import json
import pathlib
import tomllib

import yaml
from PIL import Image, ImageDraw, ImageFont

ROOT = pathlib.Path(__file__).resolve().parent.parent
W, H = 1200, 630
MONO = str(pathlib.Path.home() / "Library/Fonts/SauceCodeProNerdFont-{}.ttf")
CJK = "/System/Library/Fonts/STHeiti Medium.ttc"

profile = yaml.safe_load((ROOT / "data/profile.yaml").read_text())
config = tomllib.loads((ROOT / "config.toml").read_text())
schemes = json.loads((ROOT / "themes/terminal/data/colorschemes.json").read_text())
c = next(s for s in schemes["schemes"] if s["id"] == schemes["default_dark"])["colors"]


def font(path, size):
    return ImageFont.truetype(path, size)


def segment(draw, x, y, text, fnt, bg, fg, h=44, pad=16, arrow=14, first=False):
    """Powerline segment; returns the x where the next one starts."""
    w = draw.textlength(text, font=fnt)
    left = x if first else x - arrow
    pts = [(left, y), (x + pad + w + pad, y), (x + pad + w + pad + arrow, y + h / 2),
           (x + pad + w + pad, y + h), (left, y + h)]
    if not first:
        pts.append((x, y + h / 2))
    draw.polygon(pts, fill=bg)
    draw.text((x + pad, y + h / 2), text, font=fnt, fill=fg, anchor="lm")
    return x + pad + w + pad + arrow + 2


img = Image.new("RGB", (W, H), c["bg"])
d = ImageDraw.Draw(img)

# header bar, like the site's sticky header
d.rectangle([0, 0, W, 76], fill=c["bg-alt"])
d.line([0, 76, W, 76], fill=c["line"], width=2)
seg_font = font(MONO.format("SemiBold"), 24)
x = segment(d, 60, 16, "win", seg_font, c["blue"], c["on-accent"], first=True)
x = segment(d, x, 16, "~/about", seg_font, c["purple"], c["on-accent"])
segment(d, x, 16, "墨冊", font(CJK, 24), c["line"], c["fg-hi"])

# avatar: circle with a green ring
size = 300
avatar = Image.open(ROOT / "static" / config["params"]["avatar"].lstrip("/")).convert("RGB")
avatar = avatar.resize((size, size), Image.LANCZOS)
mask = Image.new("L", (size, size), 0)
ImageDraw.Draw(mask).ellipse([0, 0, size, size], fill=255)
ax, ay = 90, 200
d.ellipse([ax - 8, ay - 8, ax + size + 8, ay + size + 8], fill=c["green"])
img.paste(avatar, (ax, ay), mask)

# right column: ❯ whoami / name / tagline / role / url
tx = 470
d.text((tx, 170), "❯", font=font(MONO.format("Bold"), 30), fill=c["green"])
d.text((tx + 34, 170), "whoami", font=font(MONO.format("Regular"), 30), fill=c["fg-hi"])
d.text((tx, 220), "Win Yu", font=font(MONO.format("Bold"), 84), fill=c["fg-hi"])
d.text((tx, 330), profile["tagline"], font=font(CJK, 42), fill=c["green"])
role = profile["role"]
d.text((tx, 404), role["title"].split(" / ")[0] + " @ " + role["org"], font=font(CJK, 30), fill=c["fg"])
d.text((tx, 450), profile["status"], font=font(MONO.format("Regular"), 24), fill=c["muted"])
d.text((W - 60, H - 48), "kylinyu.win/about", font=font(MONO.format("Regular"), 26), fill=c["muted"], anchor="rs")

out = ROOT / "static/img/og/about.png"
out.parent.mkdir(parents=True, exist_ok=True)
img.save(out, optimize=True)
print(f"wrote {out.relative_to(ROOT)} ({W}x{H})")
