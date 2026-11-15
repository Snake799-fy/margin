"""MARGIN — 320x180 title screen (background without text) + separate MARGIN logo
(pixel art made in code, with AI: Claude)."""
from PIL import Image, ImageDraw, ImageFont
import math, os, random
from make_res_icons import PAL, rgba
from make_item_icons import C
from make_eva_events import grad, ridge, disc_on, dither_fill, specks, hab, eva, col, BAYER
from make_ui_frame import ptext

FONT = {  # 5x7
    'M': ["X...X", "XX.XX", "X.X.X", "X.X.X", "X...X", "X...X", "X...X"],
    'A': [".XXX.", "X...X", "X...X", "XXXXX", "X...X", "X...X", "X...X"],
    'R': ["XXXX.", "X...X", "X...X", "XXXX.", "X.X..", "X..X.", "X...X"],
    'G': [".XXXX", "X....", "X....", "X..XX", "X...X", "X...X", ".XXX."],
    'I': ["XXXXX", "..X..", "..X..", "..X..", "..X..", "..X..", "XXXXX"],
    'N': ["X...X", "XX..X", "X.X.X", "X.X.X", "X..XX", "X...X", "X...X"],
}

def logo(word='MARGIN', s=3, gap=3):
    w = len(word) * 5 * s + (len(word) - 1) * gap
    c = C(w + 6, 7 * s + 12)
    for i, ch in enumerate(word):
        ox = 3 + i * (5 * s + gap)
        for y, row in enumerate(FONT[ch]):
            for x, v in enumerate(row):
                if v == 'X':
                    for dy in range(s):
                        yy = 3 + y * s + dy
                        k = 'W' if yy < 3 + 2 * s else ('L' if yy < 3 + 5 * s else 'S')
                        c.R(ox + x * s, yy, ox + x * s + s - 1, yy, k)
    c.outline()
    # cast shadow
    sh = [(x + 2, y + 2) for y in range(c.h) for x in range(c.w) if c.g[y][x] != '.']
    for x, y in sh:
        if 0 <= x < c.w and 0 <= y < c.h and c.g[y][x] == '.': c.g[y][x] = 'D'
    # margin bar (green / yellow / red) under the logo
    by = 3 + 7 * s + 4; seg = (w - 4) // 3
    for i, k in enumerate('VYX'):
        c.R(3 + i * (seg + 2), by, 3 + i * (seg + 2) + seg - 1, by + 1, k)
    return c

def background(t=None, crew=True):
    im = Image.new('RGBA', (320, 180))
    grad(im, 0, 112, ['K', 'D', 'R', 'O', 'S'])
    rnd = random.Random(21)
    for i in range(40):                                     # estrelas
        x, y = rnd.randrange(320), rnd.randrange(0, 45)
        k = 'W' if rnd.random() < 0.3 else 'g'
        if t is not None:
            ph = (i * 3 + t) % 8
            if ph == 0: k = 'W'
            elif ph == 4: continue
        im.putpixel((x, y), col(k))
    disc_on(im, 58, 28, 1.2, 'g'); im.putpixel((250, 18), col('g'))   # Phobos and Deimos
    # bluish sunset (on Mars the sky around the Sun turns blue)
    pul = 0 if t is None else 0.12 * math.sin(2 * math.pi * t / 8)
    for r, ratio in ((34, 0.25 + pul), (24, 0.5 + pul), (15, 0.8 + pul / 2)):
        dither_fill(im, lambda x, y, r=r: (x - 160) ** 2 + ((y - 97) * 1.4) ** 2 <= r * r and y < 106, 'u', ratio)
    disc_on(im, 160, 97, 6, 'W'); disc_on(im, 160, 97, 4, 'L') if False else None
    ridge(im, 101, 5, [0.025, 0.07, 0.15], 'R', 31, 180)          # distant mesas
    ridge(im, 110, 3, [0.04, 0.11], 'O', 32, 180)                 # crater rim
    ridge(im, 122, 4, [0.03, 0.09, 0.2], 'R', 33, 180)            # delta / middle
    ridge(im, 140, 3, [0.05, 0.13], 'D', 34, 180)                 # foreground
    specks(im, 124, 140, ['O', 'D'], 90, 35); specks(im, 141, 180, ['R', 'K'], 160, 36)
    # sun glow on the ground
    dither_fill(im, lambda x, y: abs(x - 160) < 30 - (y - 112) * 0.6 and 112 <= y < 124, 'S', 0.3)
    c = C(320, 90); hab(c, 238, 52)                           # habitat (y relative to the crop)
    sp = Image.new('RGBA', (320, 180)); sp.alpha_composite(c.outline().img(), (0, 76))
    for i, cid in enumerate(('vega', 'okoye', 'tanaka', 'duarte')):
        if not crew: break
        e = eva(cid, 1).img().transpose(Image.Transpose.FLIP_LEFT_RIGHT)
        sp.alpha_composite(e, (196 + i * 11, 126 + (i % 2)))
    im.alpha_composite(sp)
    if t is None or t % 4 < 2: im.putpixel((251, 132), col('Y'))
    if t is None or t % 4 != 3: im.putpixel((241, 133), col('Y'))   # habitat lights
    return im

if __name__ == '__main__':
    os.makedirs('out/ui', exist_ok=True)
    bg = background(); bg.save('out/ui/title_bg.png')
    lg = logo().img(); lg.save('out/ui/logo_margin.png')
    lg2 = logo(s=2, gap=2).img(); lg2.save('out/ui/logo_margin_small.png')
    mock = bg.copy(); mock.alpha_composite(lg, ((320 - lg.width) // 2, 22))
    ptext(mock, (101, 60), 'A MARS MISSION DESIGN GAME', 'L')
    ptext(mock, (124, 160), 'CLICK TO START', 'W')
    mock.save('out/ui/_title_mock_1x.png')
    font = ImageFont.load_default(size=13)
    board = Image.new('RGBA', (1320, 1560), rgba('#2a2430')); d = ImageDraw.Draw(board)
    d.text((20, 4), 'Assembled title screen (4x) - text is a mock; the game uses a pixel font', fill='white', font=font)
    board.alpha_composite(mock.resize((1280, 720), Image.NEAREST), (20, 24))
    d.text((20, 756), 'title_bg.png (no text, 2x)  |  logo_margin.png (4x)  |  logo_margin_small.png (4x)', fill='white', font=font)
    board.alpha_composite(bg.resize((640, 360), Image.NEAREST), (20, 776))
    board.alpha_composite(lg.resize((lg.width * 4, lg.height * 4), Image.NEAREST), (680, 776))
    board.alpha_composite(lg2.resize((lg2.width * 4, lg2.height * 4), Image.NEAREST), (680, 920))
    board = board.crop((0, 0, 1320, 1150)); board.save('preview_title.png'); print('ok')
