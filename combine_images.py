#!/usr/bin/env python3
"""
将图片每 4 张合成为一张 2x2 网格图（1 2 / 3 4）.
输入: slides/img_ver/第11讲/  (59 张 2400x1800 PNG)
输出: slides/img_ver/11/       (15 张组合图)
"""

import os
from PIL import Image

BASE = os.path.dirname(os.path.abspath(__file__))
SRC_DIR = os.path.join(BASE, "slides/img_ver/第11讲")
OUT_DIR = os.path.join(BASE, "slides/img_ver/11")

TARGET_W, TARGET_H = 800, 600
CANVAS_W, CANVAS_H = TARGET_W * 2, TARGET_H * 2

os.makedirs(OUT_DIR, exist_ok=True)

files = sorted(
    [f for f in os.listdir(SRC_DIR) if f.lower(). endswith((".png", ".jpg", ".jpeg"))],
    key=lambda x: int(''.join(filter(str.isdigit, x)) or 0),
)
print(f"找到 {len(files)} 张图片")

groups = [files[i:i+4] for i in range(0, len(files), 4)]

for idx, group in enumerate(groups, 1):
    canvas = Image.new("RGB", (CANVAS_W, CANVAS_H), (255, 255, 255))

    positions = [(0, 0), (TARGET_W, 0), (0, TARGET_H), (TARGET_W, TARGET_H)]

    for i, fname in enumerate(group):
        img = Image.open(os.path.join(SRC_DIR, fname)). convert("RGBA")
        img_resized = img.resize((TARGET_W, TARGET_H), Image.LANCZOS)
        # 转 RGB 贴到白色底上
        paste = Image.new("RGB", (TARGET_W, TARGET_H), (255, 255, 255))
        paste.paste(img_resized, (0, 0), img_resized)
        canvas.paste(paste, positions[i])

    out_name = f"第11讲_grid_{idx:02d}.png"
    canvas.save(os.path.join(OUT_DIR, out_name), "PNG")
    print(f"  [{idx}/{len(groups)}] {out_name}  ({CANVAS_W}x{CANVAS_H})")

print(f"\n完成！共生成 {len(groups)} 张组合图,输出到: {OUT_DIR}")
