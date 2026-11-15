"""MARGIN — 6 resource icons 16x16 (pixel art made in code, with AI: Claude)."""
from PIL import Image, ImageDraw, ImageFont
import os

# MARGIN palette v1 (16 colors)
PAL = {
    'K': ('outline',      '#1a1020'),
    'D': ('mars_dark',    '#3b1f1a'),
    'R': ('mars_rust',    '#7a3424'),
    'O': ('mars_ochre',   '#b5552e'),
    'S': ('mars_sand',    '#d98c4a'),
    'L': ('mars_light',   '#f0c48a'),
    'G': ('gray_dark',    '#5a5a6e'),
    'g': ('gray_light',   '#a0a0b0'),
    'W': ('white',        '#f4f0e8'),
    'V': ('ok_green',     '#4fb04a'),
    'Y': ('warn_yellow',  '#f2c230'),
    'X': ('danger_red',   '#d6362f'),
    'N': ('heat_orange',  '#f07a1e'),
    'B': ('contam_brown', '#7a5230'),
    'U': ('shield_blue',  '#3a7bd5'),
    'u': ('light_blue',   '#8fc7f0'),
}

E = '.' * 16
ICONS = {
 'mass': [
  E,
  "......KKKK......",
  ".....KgggGK.....",
  ".....Kg..GK.....",
  ".....KK..KK.....",
  "....KKKKKKKK....",
  "....KgggggGK....",
  "...KggWgggGGK...",
  "...KgWggggGGK...",
  "..KggggggggGGK..",
  "..KgggggggggGK..",
  ".KggggggggggGGK.",
  ".KgggggggggggGK.",
  ".KGGGGGGGGGGGGK.",
  ".KKKKKKKKKKKKKK.",
  E],
 'power': [
  E,
  ".........KKKK...",
  "........KWYNK...",
  ".......KWYNK....",
  "......KWYNK.....",
  ".....KWYNK......",
  "....KWYYNKKKK...",
  "...KWYYYYYYNK...",
  "...KKKKYYYNK....",
  "......KYYNK.....",
  ".....KYYNK......",
  "....KYYNK.......",
  "....KYNK........",
  "....KNK.........",
  "....KK..........",
  E],
 'budget': [
  E,
  E,
  ".....KKKKKK.....",
  "...KKYYYYYYKK...",
  "..KYYLLOYYYYNK..",
  "..KYLYYOOYYYNK..",
  ".KYLYYOYYOYYYNK.",
  ".KYLYYOYYYYYYNK.",
  ".KYYYYYOOYYYYNK.",
  ".KYYYYYYYOYYYNK.",
  ".KYYYYOYYOYYYNK.",
  "..KYYYYOOYYYNK..",
  "..KYYYYYOYYNNK..",
  "...KKNNNNNNKK...",
  ".....KKKKKK.....",
  E],
 'data': [
  E,
  "....KKKKKKKK....",
  "..KKggWggggGKK..",
  ".KgggggggggggGK.",
  ".KuKKgggggGKKUK.",
  ".KWuuKKKKKKuUUK.",
  ".KWuuuuuuuuuUUK.",
  ".KKuuuuuuuuuUKK.",
  ".KuKKuuuuuuKKUK.",
  ".KWuuKKKKKKuUUK.",
  ".KWuuuuuuuuuUUK.",
  ".KWuuuuuuuuuUUK.",
  ".KKuuuuuuuuuUKK.",
  "..KKuuuuuuuUKK..",
  "....KKKKKKKK....",
  E],
 'comms': [
  E,
  ".u............u.",
  "u..U........U..u",
  "u.U...KKKK...U.u",
  "u.U..KWWgGK..U.u",
  "u.U..KgggGK..U.u",
  ".u.U..KKKK..U.u.",
  "......KgGK......",
  "......KgGK......",
  ".....KgKKGK.....",
  ".....KgKKGK.....",
  "....KgKKKKGK....",
  "....KgK..KGK....",
  "...KgK....KGK...",
  "..KKKKKKKKKKKK..",
  E],
 'time': [
  "..KKKKKKKKKKKK..",
  "..KgggggggggGK..",
  "..KKKKKKKKKKKK..",
  "...KWuLLLLLuK...",
  "....KuLLLSuK....",
  ".....KuLSuK.....",
  "......KLSK......",
  "......KuSK......",
  ".....KuuSuK.....",
  "....KuuuSuuK....",
  "...KuuLLSLLuK...",
  "...KLLLLLLSSK...",
  "..KKKKKKKKKKKK..",
  "..KgggggggggGK..",
  "..KKKKKKKKKKKK..",
  E],
}

def rgba(h):
    h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)

def render(rows):
    assert len(rows) == 16, len(rows)
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    for y, row in enumerate(rows):
        assert len(row) == 16, (y, row, len(row))
        for x, c in enumerate(row):
            if c != '.':
                im.putpixel((x, y), rgba(PAL[c][1]))
    return im

out = 'out'
os.makedirs(f'{out}/ui', exist_ok=True)
os.makedirs(f'{out}/palette', exist_ok=True)
order = ['mass', 'power', 'budget', 'data', 'comms', 'time']
imgs = {k: render(ICONS[k]) for k in order}
for k, im in imgs.items():
    im.save(f'{out}/ui/res_{k}.png')

# sprite sheet 96x16, fixed order
sheet = Image.new('RGBA', (16 * len(order), 16), (0, 0, 0, 0))
for i, k in enumerate(order):
    sheet.paste(imgs[k], (16 * i, 0))
sheet.save(f'{out}/ui/res_icons_sheet.png')

# palette: .hex (Aseprite/Lospec), .gpl (GIMP/Aseprite) and png 16x1
with open(f'{out}/palette/margin_palette.hex', 'w') as f:
    f.write('\n'.join(v[1].lstrip('#') for v in PAL.values()) + '\n')
with open(f'{out}/palette/margin_palette.gpl', 'w') as f:
    f.write('GIMP Palette\nName: MARGIN v1\nColumns: 8\n#\n')
    for name, h in PAL.values():
        r, g, b, _ = rgba(h); f.write(f'{r:3d} {g:3d} {b:3d}\t{name}\n')
pal_img = Image.new('RGBA', (16, 1))
for i, (_, h) in enumerate(PAL.values()):
    pal_img.putpixel((i, 0), rgba(h))
pal_img.save(f'{out}/palette/margin_palette.png')

# approval board: icons at 8x on 3 backgrounds + actual size 1x/2x/4x
S = 8
labels = ['Mass', 'Power', 'Budget', 'Data', 'Comms', 'Time']
bgs = [('Dark UI', '#1e1a24'), ('Mars (ochre)', '#b5552e'), ('Light', '#e8e0d0')]
cell = 16 * S + 24
W = 20 + cell * 6
H = 40 + len(bgs) * (16 * S + 24) + 120 + 70
board = Image.new('RGBA', (W, H), rgba('#2a2430'))
d = ImageDraw.Draw(board)
font = ImageFont.load_default(size=14)
for i, lab in enumerate(labels):
    d.text((20 + i * cell + 4, 12), lab, fill='white', font=font)
y = 36
for name, bg in bgs:
    for i, k in enumerate(order):
        x = 20 + i * cell
        d.rectangle([x - 4, y - 4, x + 16 * S + 3, y + 16 * S + 3], fill=bg)
        board.alpha_composite(imgs[k].resize((16 * S, 16 * S), Image.NEAREST), (x, y))
    d.text((W - 10, y + 16 * S // 2), '', fill='white')
    y += 16 * S + 24
# actual size
d.text((20, y), 'Actual size 1x / 2x / 4x (as it looks in the game at 320x180 scaled):', fill='white', font=font)
y += 22
xx = 20
for s in (1, 2, 4):
    sw = sheet.resize((96 * s, 16 * s), Image.NEAREST)
    d.rectangle([xx - 4, y - 4, xx + 96 * s + 3, y + 16 * s + 3], fill='#1e1a24')
    board.alpha_composite(sw, (xx, y))
    xx += 96 * s + 24
y += 16 * 4 + 20
# palette
d.text((20, y), 'MARGIN palette v1 (16 colors)', fill='white', font=font)
y += 22
for i, (_, h) in enumerate(PAL.values()):
    d.rectangle([20 + i * 44, y, 20 + i * 44 + 38, y + 24], fill=h)
board.save('preview_res_icons.png')
print('ok', board.size)
