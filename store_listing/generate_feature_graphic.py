from PIL import Image, ImageDraw, ImageFont
import math

W, H = 1024, 500
img = Image.new("RGB", (W, H))

# Gradient background: deep purple left to lighter purple-blue right
for x in range(W):
    t = x / W
    r = int(60 * (1 - t) + 100 * t)
    g = int(30 * (1 - t) + 70 * t)
    b = int(120 * (1 - t) + 180 * t)
    for y in range(H):
        img.putpixel((x, y), (r, g, b))

draw = ImageDraw.Draw(img)
gold = (212, 168, 67)

# Decorative crescent on the left
moon_cx, moon_cy = 160, 250
moon_r = 100
moon_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
md = ImageDraw.Draw(moon_layer)
md.ellipse([moon_cx - moon_r, moon_cy - moon_r, moon_cx + moon_r, moon_cy + moon_r], fill=(*gold, 60))
crescent_mask = moon_layer.split()[3].copy()
cd = ImageDraw.Draw(crescent_mask)
cd.ellipse([moon_cx + 45 - 85, moon_cy - 15 - 85, moon_cx + 45 + 85, moon_cy - 15 + 85], fill=0)
moon_layer.putalpha(crescent_mask)
img_rgba = img.convert("RGBA")
img_rgba = Image.alpha_composite(img_rgba, moon_layer)

# Another decorative crescent on the right, smaller
moon2_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
md2 = ImageDraw.Draw(moon2_layer)
m2cx, m2cy, m2r = 900, 380, 60
md2.ellipse([m2cx - m2r, m2cy - m2r, m2cx + m2r, m2cy + m2r], fill=(*gold, 40))
cm2 = moon2_layer.split()[3].copy()
cd2 = ImageDraw.Draw(cm2)
cd2.ellipse([m2cx + 30 - 50, m2cy - 10 - 50, m2cx + 30 + 50, m2cy - 10 + 50], fill=0)
moon2_layer.putalpha(cm2)
img_rgba = Image.alpha_composite(img_rgba, moon2_layer)

# Small decorative stars
star_layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
sd = ImageDraw.Draw(star_layer)
stars = [(120, 100, 10, 50), (250, 60, 8, 35), (800, 80, 12, 45), (950, 200, 7, 30), (700, 420, 9, 25)]
for sx, sy, sr_out, alpha in stars:
    sr_in = sr_out // 2
    pts = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = sr_out if i % 2 == 0 else sr_in
        pts.append((sx + r * math.cos(angle), sy + r * math.sin(angle)))
    sd.polygon(pts, fill=(*gold, alpha))
img_rgba = Image.alpha_composite(img_rgba, star_layer)

draw = ImageDraw.Draw(img_rgba)

try:
    font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 72)
    font_sub = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 30)
    font_features = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 24)
except OSError:
    font_title = ImageFont.load_default()
    font_sub = ImageFont.load_default()
    font_features = ImageFont.load_default()

# Title centered
title_y = 120
qalb_bb = draw.textbbox((0, 0), "Qalb", font=font_title)
care_bb = draw.textbbox((0, 0), "Care", font=font_title)
qw = qalb_bb[2] - qalb_bb[0]
cw = care_bb[2] - care_bb[0]
tw = qw + cw
tx = (W - tw) // 2

draw.text((tx, title_y), "Qalb", fill=(255, 255, 255), font=font_title)
draw.text((tx + qw, title_y), "Care", fill=gold, font=font_title)

# Tagline
tagline = "Your Daily Islamic Companion"
tb = draw.textbbox((0, 0), tagline, font=font_sub)
draw.text(((W - (tb[2] - tb[0])) // 2, 210), tagline, fill=(230, 230, 245), font=font_sub)

# Feature bullets
features = [
    "Prayer Times  ·  Quran Reader  ·  Qibla Finder",
    "Duas Collection  ·  Hijri Calendar  ·  Daily Ayah",
]
y = 290
for feat in features:
    fb = draw.textbbox((0, 0), feat, font=font_features)
    draw.text(((W - (fb[2] - fb[0])) // 2, y), feat, fill=(200, 200, 220), font=font_features)
    y += 40

# Thin gold line separator
line_y = 270
draw.line([(W // 2 - 200, line_y), (W // 2 + 200, line_y)], fill=(*gold, 150), width=2)

# Bottom accent line
draw.rectangle([0, H - 4, W, H], fill=gold)

img_rgba.convert("RGB").save("/home/user/IslamicApp/store_listing/feature_graphic_1024x500.png")
print("Feature graphic saved.")
