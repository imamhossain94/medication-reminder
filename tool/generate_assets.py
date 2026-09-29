"""Generates the launcher icon and the launch background for the app.

Run with:  python tool/generate_assets.py

Everything is drawn from scratch so the repository does not need to ship the
original design files.
"""

import math
import os

from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ANDROID_RES = os.path.join(ROOT, "android", "app", "src", "main", "res")

# Brand colours (see lib/utils/constants.dart)
PRIMARY_A = (124, 77, 255)
PRIMARY_B = (108, 76, 224)
TEAL = (0, 194, 168)


def gradient(size, top, bottom, diagonal=False):
    """Linear (or diagonal) two-colour gradient as an RGB image."""
    w, h = size
    img = Image.new("RGB", size)
    px = img.load()
    for y in range(h):
        for x in range(w):
            if diagonal:
                t = (x / max(1, w - 1) + y / max(1, h - 1)) / 2
            else:
                t = y / max(1, h - 1)
            px[x, y] = (
                int(top[0] + (bottom[0] - top[0]) * t),
                int(top[1] + (bottom[1] - top[1]) * t),
                int(top[2] + (bottom[2] - top[2]) * t),
            )
    return img


def draw_pill(draw, cx, cy, length, width, angle, colour):
    """A capsule (pill) rotated by `angle` degrees.

    `length` is the length of the straight part; the round caps add `width`.
    """
    rad = math.radians(angle)
    dx, dy = math.cos(rad) * length / 2, math.sin(rad) * length / 2
    w = max(1, int(round(width)))
    draw.line(
        [(int(cx - dx), int(cy - dy)), (int(cx + dx), int(cy + dy))],
        fill=colour,
        width=w,
    )
    r = w / 2
    for x, y in ((cx - dx, cy - dy), (cx + dx, cy + dy)):
        draw.ellipse(
            [int(x - r), int(y - r), int(x + r), int(y + r)], fill=colour
        )


def pill_on_transparent(size, scale=1.0):
    """The pill glyph alone, on transparency, for adaptive-icon layers."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    s = size / 100.0
    length, width = 46 * s * scale, 21 * s * scale
    cx, cy = 50 * s, 50 * s
    draw_pill(draw, cx, cy, length, width, -38, (255, 255, 255, 255))
    # The right half of the capsule in mint; shorten by half a cap so the two
    # halves line up exactly.
    half = max(1, length / 2 - width / 2)
    draw_pill(draw, cx, cy, half, width, -38, TEAL + (255,))
    return img


def make_icon(size, round_icon=False):
    """Legacy (pre-Android 8) app icon: gradient + pill."""
    img = gradient((size, size), PRIMARY_A, PRIMARY_B, diagonal=True)
    draw = ImageDraw.Draw(img)

    s = size / 100.0

    # Soft highlight
    glow = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [-size * 0.25, -size * 0.45, size * 0.85, size * 0.45],
        fill=(255, 255, 255, 38),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.12))
    img = Image.alpha_composite(img.convert("RGBA"), glow)
    img.alpha_composite(pill_on_transparent(size))
    img = img.convert("RGB")

    if round_icon:
        mask = Image.new("L", (size, size), 0)
        ImageDraw.Draw(mask).ellipse([0, 0, size - 1, size - 1], fill=255)
        out = Image.new("RGB", (size, size), (255, 255, 255))
        out.paste(img, (0, 0), mask)
        return out
    return img


def make_launch_background(w, h):
    """Flat brand-coloured window background with a soft radial glow."""
    img = gradient((w, h), (75, 45, 177), (20, 16, 38), diagonal=True)
    glow = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse(
        [w * 0.15, h * 0.18, w * 0.85, h * 0.62], fill=(0, 194, 168, 40)
    )
    glow = glow.filter(ImageFilter.GaussianBlur(w * 0.12))
    return Image.alpha_composite(img.convert("RGBA"), glow).convert("RGB")


# Android launcher icon densities: folder -> foreground size in px.
DENSITIES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background" />
    <foreground android:drawable="@mipmap/ic_launcher_foreground" />
</adaptive-icon>
"""


def main():
    for folder, px in DENSITIES.items():
        out_dir = os.path.join(ANDROID_RES, folder)
        os.makedirs(out_dir, exist_ok=True)
        make_icon(px).save(os.path.join(out_dir, "ic_launcher.png"))
        make_icon(px, round_icon=True).save(
            os.path.join(out_dir, "ic_launcher_round.png")
        )
        # Adaptive foregrounds are 108dp; keep the glyph inside the 66dp safe
        # zone, hence the 0.62 scale.
        pill_on_transparent(int(px * 108 / 48), scale=0.62).save(
            os.path.join(out_dir, "ic_launcher_foreground.png")
        )
        print("wrote", folder)

    anydpi = os.path.join(ANDROID_RES, "mipmap-anydpi-v26")
    os.makedirs(anydpi, exist_ok=True)
    for name in ("ic_launcher.xml", "ic_launcher_round.xml"):
        with open(os.path.join(anydpi, name), "w", encoding="utf-8") as fh:
            fh.write(ADAPTIVE_XML)
    print("wrote mipmap-anydpi-v26")

    drawable = os.path.join(ANDROID_RES, "drawable")
    os.makedirs(drawable, exist_ok=True)
    make_launch_background(720, 1280).save(
        os.path.join(drawable, "launch_background.png")
    )
    print("wrote drawable/launch_background.png")

    values = os.path.join(ANDROID_RES, "values")
    os.makedirs(values, exist_ok=True)
    with open(os.path.join(values, "colors.xml"), "w", encoding="utf-8") as fh:
        fh.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            "<resources>\n"
            '    <color name="ic_launcher_background">#6C4CE0</color>\n'
            '    <color name="splash_background">#4B31B4</color>\n'
            "</resources>\n"
        )
    print("wrote values/colors.xml")


if __name__ == "__main__":
    main()
