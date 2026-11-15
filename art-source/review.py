"""Review sheet: each row = one animation (frames side by side, enlarged)."""
import json, sys
from PIL import Image, ImageDraw, ImageFont
man = json.load(open('out/anim/anim_manifest.json'))
filt = sys.argv[1] if len(sys.argv) > 1 else ''
scale = int(sys.argv[2]) if len(sys.argv) > 2 else 4
out = sys.argv[3] if len(sys.argv) > 3 else '/tmp/review.png'
rows = []
for ent, e in man.items():
    if filt not in ent: continue
    for name, a in e['animations'].items():
        p = a['sheet'].replace('res://art/anim', 'out/anim')
        rows.append((f'{ent}.{name} ({a["frames"]}f {a["fps"]}fps)', Image.open(p), a))
font = ImageFont.load_default(size=12)
W = max(r[1].width * scale + a['frames'] * 6 for _, _, a in rows for r in [(0, _)]) + 260 if rows else 400
W = max(r[1].width * scale + r[2]['frames'] * 6 for r in rows) + 260
H = sum(r[1].height * scale + 10 for r in rows) + 10
im = Image.new('RGBA', (W, H), (42, 36, 48, 255)); d = ImageDraw.Draw(im)
y = 6
for label, strip, a in rows:
    d.text((6, y), label, fill='white', font=font)
    for j in range(a['frames']):
        fr = strip.crop((j * a['frame_w'], 0, (j + 1) * a['frame_w'], a['frame_h'])).resize((a['frame_w'] * scale, a['frame_h'] * scale), Image.NEAREST)
        bg = Image.new('RGBA', fr.size, (217, 140, 74, 255) if a['frame_w'] <= 48 else (26, 16, 32, 255)); bg.alpha_composite(fr)
        im.alpha_composite(bg, (254 + j * (a['frame_w'] * scale + 6), y))
    y += a['frame_h'] * scale + 10
im.save(out); print(out, im.size)
