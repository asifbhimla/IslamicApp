from PIL import Image, ImageDraw, ImageFont
import math

SIZE = 512
RADIUS = 100

# --- Build the gradient background on a separate layer ---
bg = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
cx, cy = SIZE // 2, SIZE // 2
for y in range(SIZE):
    for x in range(SIZE):
        dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2) / (SIZE * 0.7)
        dist = min(dist, 1.0)
        r = int(123 * (1 - dist * 0.4) + 40 * dist)
        g = int(94 * (1 - dist * 0.5) + 20 * dist)
        b = int(167 * (1 - dist * 0.3) + 80 * dist)
        bg.putpixel((x, y), (r, g, b, 255))

# Rounded-corner mask for background
bg_mask = Image.new("L", (SIZE, SIZE), 0)
ImageDraw.Draw(bg_mask).rounded_rectangle([0, 0, SIZE - 1, SIZE - 1], radius=RADIUS, fill=255)
bg.putalpha(bg_mask)

# --- Draw the crescent moon as a masked gold circle ---
gold = (212, 168, 67)  # #D4A843

moon_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
moon_draw = ImageDraw.Draw(moon_layer)

moon_cx, moon_cy = 256, 185
moon_r = 80
moon_draw.ellipse(
    [moon_cx - moon_r, moon_cy - moon_r, moon_cx + moon_r, moon_cy + moon_r],
    fill=gold,
)

# Erase a circle to create the crescent shape (draw transparent)
cut_r = 70
cut_cx = moon_cx + 38
cut_cy = moon_cy - 12
# Draw black on a mask, then punch it out
crescent_mask = moon_layer.split()[3].copy()  # alpha channel
cut_draw = ImageDraw.Draw(crescent_mask)
cut_draw.ellipse(
    [cut_cx - cut_r, cut_cy - cut_r, cut_cx + cut_r, cut_cy + cut_r],
    fill=0,  # transparent
)
moon_layer.putalpha(crescent_mask)

# --- Draw a star ---
star_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
star_draw = ImageDraw.Draw(star_layer)
star_cx, star_cy = 330, 135
star_r_outer = 18
star_r_inner = 8
points = []
for i in range(10):
    angle = math.radians(i * 36 - 90)
    r = star_r_outer if i % 2 == 0 else star_r_inner
    points.append((star_cx + r * math.cos(angle), star_cy + r * math.sin(angle)))
star_draw.polygon(points, fill=gold)

# --- Composite ---
img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
img = Image.alpha_composite(img, bg)
img = Image.alpha_composite(img, moon_layer)
img = Image.alpha_composite(img, star_layer)

# --- Text ---
draw = ImageDraw.Draw(img)
try:
    font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 64)
    font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 26)
except OSError:
    font_large = ImageFont.load_default()
    font_small = ImageFont.load_default()

text_y = 305
qalb_bbox = draw.textbbox((0, 0), "Qalb", font=font_large)
care_bbox = draw.textbbox((0, 0), "Care", font=font_large)
qalb_w = qalb_bbox[2] - qalb_bbox[0]
care_w = care_bbox[2] - care_bbox[0]
total_w = qalb_w + care_w
start_x = (SIZE - total_w) // 2

draw.text((start_x, text_y), "Qalb", fill=(255, 255, 255), font=font_large)
draw.text((start_x + qalb_w, text_y), "Care", fill=gold, font=font_large)

subtitle = "Islamic Companion"
sub_bbox = draw.textbbox((0, 0), subtitle, font=font_small)
sub_w = sub_bbox[2] - sub_bbox[0]
draw.text(((SIZE - sub_w) // 2, 380), subtitle, fill=(220, 220, 240, 180), font=font_small)

img.save("/home/user/IslamicApp/store_listing/app_icon_512.png")
print("Icon saved.")
