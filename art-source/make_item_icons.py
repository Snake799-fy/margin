"""MARGIN — grid item icons (pixel art made in code, with AI: Claude).
Size = 16 px per cell (w x h from data/game-data.json). Automatic outline in K."""
from PIL import Image, ImageDraw, ImageFont
import math, os
from make_res_icons import PAL, rgba  # same palette v1

class C:
    def __init__(s, w, h): s.w, s.h = w, h; s.g = [['.'] * w for _ in range(h)]
    def P(s, x, y, c):
        if 0 <= x < s.w and 0 <= y < s.h: s.g[y][x] = c
    def R(s, x0, y0, x1, y1, c):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1): s.P(x, y, c)
    def L(s, x0, y0, x1, y1, c):
        dx, dy = abs(x1 - x0), -abs(y1 - y0); sx = 1 if x0 < x1 else -1; sy = 1 if y0 < y1 else -1; e = dx + dy
        while True:
            s.P(x0, y0, c)
            if x0 == x1 and y0 == y1: break
            e2 = 2 * e
            if e2 >= dy: e += dy; x0 += sx
            if e2 <= dx: e += dx; y0 += sy
    def box(s, x0, y0, x1, y1, f, hi, sh):
        s.R(x0, y0, x1, y1, f); s.R(x0, y0, x1, y0, hi); s.R(x0, y0, x0, y1, hi)
        s.R(x0, y1, x1, y1, sh); s.R(x1, y0, x1, y1, sh)
    def disc(s, cx, cy, r, c):
        for y in range(s.h):
            for x in range(s.w):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r * 0.8: s.P(x, y, c)
    def ring(s, cx, cy, r, c):
        for y in range(s.h):
            for x in range(s.w):
                d = math.hypot(x - cx, y - cy)
                if abs(d - r) < 0.55: s.P(x, y, c)
    def outline(s):
        add = []
        for y in range(s.h):
            for x in range(s.w):
                if s.g[y][x] == '.':
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        xx, yy = x + dx, y + dy
                        if 0 <= xx < s.w and 0 <= yy < s.h and s.g[yy][xx] not in '.K':
                            add.append((x, y)); break
        for x, y in add: s.g[y][x] = 'K'
        return s
    def img(s):
        im = Image.new('RGBA', (s.w, s.h), (0, 0, 0, 0))
        for y in range(s.h):
            for x in range(s.w):
                c = s.g[y][x]
                if c != '.': im.putpixel((x, y), rgba(PAL[c][1]))
        return im

def fsp():  # 2x2 fission reactor (concept) — umbrella radiators + hot core
    c = C(32, 32)
    for y in range(3, 18):
        hw = 13 - (y - 3) * 9 / 14
        x0, x1 = round(15.5 - hw), round(15.5 + hw)
        c.R(x0, y, x1, y, 'g')
        for x in range(x0, x1 + 1):
            if (x - 1) % 4 == 0: c.P(x, y, 'G')
        c.P(x1, y, 'G')
    c.R(3, 3, 28, 3, 'W')
    c.R(10, 17, 21, 17, 'N')            # heat glow at the base of the radiators
    c.R(14, 18, 17, 19, 'G')            # mast
    c.box(9, 20, 22, 29, 'g', 'W', 'G')  # reactor vessel
    c.R(10, 21, 21, 21, 'N')
    for x in range(10, 22):              # hazard stripe
        col = 'Y' if ((x - 10) // 2) % 2 == 0 else 'K'
        c.P(x, 24, col); c.P(x, 25, col)
    c.R(9, 30, 11, 30, 'G'); c.R(20, 30, 22, 30, 'G')
    return c.outline()

def solar():  # 2x1 solar panel
    c = C(32, 16)
    c.R(1, 2, 30, 10, 'g')
    c.R(2, 3, 29, 9, 'U')
    for x in range(2, 30):
        for y in range(3, 10):
            if (x - 1) % 4 == 0 or y == 6: c.P(x, y, 'g')
            elif (x - 2) % 4 == 0 and y in (3, 7): c.P(x, y, 'u')
    c.R(7, 11, 8, 13, 'G'); c.R(23, 11, 24, 13, 'G'); c.R(4, 14, 27, 14, 'G')
    return c.outline()

def battery():
    c = C(16, 16)
    c.R(6, 1, 9, 1, 'G')
    c.box(4, 2, 11, 13, 'g', 'W', 'G')
    c.R(5, 4, 10, 12, 'K')
    for y, col in ((5, 'G'), (7, 'V'), (9, 'V'), (11, 'V')): c.R(6, y, 9, y, col)
    return c.outline()

def eclss():  # 2x1 life support — ventilation + recycling
    c = C(32, 16)
    c.box(1, 2, 30, 13, 'g', 'W', 'G')
    c.disc(8, 8, 4, 'G'); c.ring(8, 8, 4, 'K')
    c.L(5, 5, 11, 11, 'g'); c.L(5, 11, 11, 5, 'g'); c.P(8, 8, 'W')
    c.R(15, 4, 28, 11, 'G')
    c.ring(21.5, 7.5, 2.6, 'V')
    c.P(23, 4, 'G'); c.P(24, 5, 'G'); c.P(24, 4, 'V'); c.P(25, 5, 'V'); c.P(24, 6, 'V')  # arrow
    c.P(26, 10, 'V'); c.P(27, 10, 'Y'); c.P(16, 10, 'u'); c.P(17, 10, 'u')
    return c.outline()

def water():  # water tank (blue = also shielding)
    c = C(16, 16)
    c.R(6, 1, 9, 1, 'G')
    c.box(3, 2, 12, 12, 'u', 'W', 'U')
    for x, y in ((3, 2), (12, 2), (3, 12), (12, 12)): c.P(x, y, '.')
    c.R(3, 4, 12, 4, 'g'); c.R(3, 10, 12, 10, 'g')
    c.R(7, 5, 8, 5, 'W'); c.R(6, 6, 9, 8, 'W'); c.R(7, 9, 8, 9, 'W')
    c.R(4, 13, 5, 13, 'G'); c.R(10, 13, 11, 13, 'G')
    return c.outline()

def crate():  # supply crate (O2, water, food)
    c = C(16, 16)
    c.R(2, 3, 13, 13, 'R'); c.R(3, 4, 12, 12, 'S')
    c.R(3, 4, 12, 4, 'L'); c.R(3, 8, 12, 8, 'O')
    c.L(3, 12, 12, 4, 'L'); c.L(4, 12, 12, 5, 'O')
    return c.outline()

def shelter():  # 2x1 solar storm shelter
    c = C(32, 16)
    c.R(5, 3, 26, 3, 'W'); c.R(3, 4, 28, 4, 'g'); c.R(2, 5, 29, 13, 'g')
    c.R(3, 4, 28, 4, 'W'); c.R(2, 13, 29, 13, 'G'); c.R(29, 5, 29, 13, 'G')
    for x in (6, 7, 24, 25): c.R(x, 4 if x in (6, 25) else 4, x, 12, 'U')
    c.R(6, 3, 7, 3, 'U'); c.R(24, 3, 25, 3, 'U')
    c.R(14, 7, 17, 13, 'G'); c.R(15, 8, 16, 9, 'u')
    c.R(10, 7, 11, 8, 'Y'); c.R(20, 7, 21, 8, 'Y')
    return c.outline()

def wheel(c, cx, cy, r):
    c.disc(cx, cy, r, 'G'); c.ring(cx, cy, r, 'K'); c.P(cx, cy, 'g')

def rover_pressurized():  # 2x2
    c = C(32, 32)
    c.L(24, 4, 24, 9, 'G'); c.R(22, 3, 26, 3, 'g')
    c.R(4, 10, 27, 10, 'W'); c.R(3, 11, 29, 22, 'W'); c.R(4, 23, 28, 23, 'g')
    c.R(3, 22, 29, 22, 'g'); c.R(29, 11, 29, 22, 'g')
    c.R(22, 12, 28, 16, 'U'); c.R(23, 12, 27, 13, 'u')     # windshield
    c.R(7, 13, 9, 15, 'U'); c.R(12, 13, 14, 15, 'U'); c.P(7, 13, 'u'); c.P(12, 13, 'u')
    c.R(16, 12, 19, 20, 'g'); c.R(17, 13, 18, 14, 'u')    # hatch
    c.R(3, 18, 15, 18, 'U'); c.R(20, 18, 29, 18, 'U')     # shielding stripe
    for x in (7, 16, 25): wheel(c, x, 26, 3)
    return c.outline()

def rover_open():  # 2x1
    c = C(32, 16)
    c.L(25, 2, 25, 6, 'G'); c.R(22, 1, 28, 1, 'g'); c.R(23, 2, 27, 2, 'g')
    c.R(9, 4, 10, 7, 'G'); c.R(15, 4, 16, 7, 'G')        # seats
    c.R(2, 8, 29, 9, 'g'); c.R(2, 8, 29, 8, 'W'); c.R(2, 10, 29, 10, 'G')
    c.R(21, 5, 23, 7, 'g'); c.P(22, 6, 'V')               # console
    for x in (6, 25): wheel(c, x, 12, 3)
    return c.outline()

def suits():  # extra suits
    c = C(16, 16)
    c.R(6, 1, 9, 1, 'W'); c.R(5, 2, 10, 5, 'W')
    c.R(6, 2, 9, 4, 'S'); c.P(6, 2, 'L'); c.P(7, 2, 'L')
    c.R(4, 6, 11, 11, 'W'); c.R(11, 6, 11, 11, 'g'); c.R(4, 11, 11, 11, 'g')
    c.R(2, 6, 3, 10, 'W'); c.R(12, 6, 13, 10, 'g')
    c.R(6, 7, 9, 8, 'g'); c.P(7, 7, 'X'); c.P(8, 7, 'V')
    c.R(5, 12, 7, 14, 'W'); c.R(8, 12, 10, 14, 'g'); c.R(5, 14, 7, 14, 'G'); c.R(8, 14, 10, 14, 'G')
    return c.outline()

def field_kit():  # field kit + drill (contaminant = brown)
    c = C(16, 16)
    c.R(6, 1, 9, 3, 'g'); c.R(6, 1, 9, 1, 'W'); c.R(9, 1, 9, 3, 'G')
    for y in range(4, 9): c.R(7, y, 8, y, 'g' if y % 2 else 'G')
    c.R(5, 8, 10, 8, 'B')
    c.box(2, 9, 13, 13, 'B', 'S', 'R'); c.R(2, 11, 13, 11, 'R'); c.R(7, 10, 8, 10, 'Y')
    return c.outline()

def sample_containers():  # sterile tubes (clean)
    c = C(16, 16)
    for x in (3, 7, 11):
        c.R(x, 2, x + 1, 3, 'V')
        c.R(x, 4, x + 1, 11, 'W'); c.P(x + 1, 5, 'u')
        c.R(x, 9, x + 1, 11, 'S')
    c.R(2, 8, 13, 9, 'g'); c.R(2, 12, 13, 13, 'g'); c.R(2, 13, 13, 13, 'G')
    return c.outline()

def spectrometer():
    c = C(16, 16)
    c.R(6, 1, 9, 1, 'g')
    c.box(3, 2, 12, 13, 'G', 'g', 'K')
    c.R(4, 3, 11, 8, 'K')
    for x, h, col in ((5, 2, 'U'), (6, 4, 'V'), (7, 3, 'V'), (8, 5, 'Y'), (9, 2, 'N'), (10, 3, 'X')):
        c.R(x, 8 - h, x, 7, col)
    c.P(5, 10, 'V'); c.P(7, 10, 'g'); c.P(9, 10, 'g'); c.R(5, 12, 10, 12, 'g')
    return c.outline()

def gpr():  # 1x2 ground-penetrating radar
    c = C(16, 32)
    c.R(3, 2, 8, 3, 'G')                       # handle
    c.L(7, 3, 11, 19, 'g'); c.L(8, 3, 12, 19, 'G')
    c.R(6, 9, 11, 13, 'K'); c.R(7, 10, 10, 12, 'K')
    for x, y in ((7, 11), (8, 10), (9, 12), (10, 11)): c.P(x, y, 'V')
    c.box(2, 20, 13, 26, 'Y', 'W', 'N'); c.R(4, 22, 11, 23, 'K'); c.R(5, 22, 6, 22, 'Y')
    c.disc(4, 28, 1, 'G'); c.disc(11, 28, 1, 'G')
    return c.outline()

def met():  # weather station
    c = C(16, 16)
    c.R(2, 3, 13, 3, 'g'); c.R(2, 2, 3, 3, 'W'); c.R(12, 2, 13, 3, 'W')
    c.R(7, 1, 8, 2, 'Y')
    c.R(7, 4, 8, 12, 'g'); c.R(8, 4, 8, 12, 'G')
    c.box(5, 7, 10, 9, 'W', 'W', 'g'); c.P(6, 8, 'u')
    c.L(7, 13, 4, 14, 'G'); c.L(8, 13, 11, 14, 'G'); c.R(7, 13, 8, 14, 'G')
    return c.outline()

def medkit():  # medical kit (white cross on green — first-aid standard)
    c = C(16, 16)
    c.R(6, 2, 9, 2, 'g'); c.P(6, 3, 'g'); c.P(9, 3, 'g')
    c.R(2, 4, 13, 13, 'V'); c.R(2, 4, 13, 4, 'W'); c.R(2, 13, 13, 13, 'G'); c.R(13, 4, 13, 13, 'G')
    c.R(7, 6, 8, 11, 'W'); c.R(5, 8, 10, 9, 'W')
    return c.outline()

def hga():  # 1x2 high-gain antenna
    c = C(16, 32)
    c.disc(7.5, 7.5, 6, 'W'); c.ring(7.5, 7.5, 6, 'g')
    c.ring(7.5, 7.5, 3.5, 'g'); c.R(7, 7, 8, 8, 'G')
    for x, y in ((3, 4), (4, 3)): c.P(x, y, 'u')
    c.R(7, 14, 8, 27, 'g'); c.R(8, 14, 8, 27, 'G')
    c.L(7, 26, 3, 29, 'G'); c.L(8, 26, 12, 29, 'G'); c.R(6, 28, 9, 29, 'G')
    return c.outline()

def uhf():  # UHF radio (relay)
    c = C(16, 16)
    c.R(11, 1, 11, 6, 'g'); c.P(11, 1, 'W')
    c.P(13, 2, 'u'); c.P(14, 3, 'u'); c.P(13, 4, 'u')
    c.box(2, 7, 13, 13, 'G', 'g', 'K'); c.R(3, 13, 12, 13, 'K')
    c.R(4, 9, 8, 11, 'K'); c.R(5, 10, 7, 10, 'V')
    c.P(10, 9, 'W'); c.P(11, 11, 'W'); c.P(10, 11, 'g'); c.P(11, 9, 'g')
    return c.outline()

def spares():  # spare parts (gear)
    c = C(16, 16)
    c.disc(7.5, 7.5, 4.5, 'g')
    for a in range(8):
        t = a * math.pi / 4
        x, y = 7.5 + 5.6 * math.cos(t), 7.5 + 5.6 * math.sin(t)
        c.R(round(x - 0.5), round(y - 0.5), round(x + 0.5), round(y + 0.5), 'g')
    for x in range(16):
        for y in range(16):
            if c.g[y][x] == 'g' and x + y >= 19: c.g[y][x] = 'G'
            elif c.g[y][x] == 'g' and x + y <= 10: c.g[y][x] = 'W'
    c.R(7, 7, 8, 8, '.')
    return c.outline()

ITEMS = {  # id: (function, w, h)
    'fsp': (fsp, 2, 2), 'solar': (solar, 2, 1), 'battery': (battery, 1, 1), 'eclss': (eclss, 2, 1),
    'water': (water, 1, 1), 'crate': (crate, 1, 1), 'shelter': (shelter, 2, 1),
    'rover_pressurized': (rover_pressurized, 2, 2), 'rover_open': (rover_open, 2, 1), 'suits': (suits, 1, 1),
    'field_kit': (field_kit, 1, 1), 'sample_containers': (sample_containers, 1, 1),
    'spectrometer': (spectrometer, 1, 1), 'gpr': (gpr, 1, 2), 'met': (met, 1, 1), 'medkit': (medkit, 1, 1),
    'hga': (hga, 1, 2), 'uhf': (uhf, 1, 1), 'spares': (spares, 1, 1),
}

if __name__ == '__main__':
    os.makedirs('out/items', exist_ok=True)
    imgs = {}
    for k, (fn, w, h) in ITEMS.items():
        im = fn().img(); assert im.size == (16 * w, 16 * h), k
        im.save(f'out/items/item_{k}.png'); imgs[k] = im

    # board: all items on the lander's 7x5 grid (31 cells taken)
    layout = {'fsp': (0, 0), 'rover_pressurized': (2, 0), 'gpr': (4, 0), 'hga': (5, 0), 'battery': (6, 0),
              'water': (6, 1), 'solar': (0, 2), 'eclss': (2, 2), 'shelter': (4, 2), 'crate': (6, 2),
              'rover_open': (0, 3), 'suits': (2, 3), 'field_kit': (3, 3), 'sample_containers': (4, 3),
              'spectrometer': (5, 3), 'met': (6, 3), 'medkit': (0, 4), 'uhf': (1, 4), 'spares': (2, 4)}
    grid = Image.new('RGBA', (112, 80), rgba('#1e1a24'))
    gd = ImageDraw.Draw(grid)
    for i in range(8): gd.line([(i * 16, 0), (i * 16, 79)], fill=rgba('#3a3244'))
    for j in range(6): gd.line([(0, j * 16), (111, j * 16)], fill=rgba('#3a3244'))
    for k, (gx, gy) in layout.items(): grid.alpha_composite(imgs[k], (gx * 16, gy * 16))
    grid.save('out/items/_grid_preview_1x.png')

    S = 6
    big = grid.resize((112 * S, 80 * S), Image.NEAREST)
    font = ImageFont.load_default(size=13)
    W, H = 112 * S + 40 + 260, 80 * S + 40 + 240
    board = Image.new('RGBA', (W, H), rgba('#2a2430'))
    d = ImageDraw.Draw(board)
    d.text((20, 6), 'Lander 7x5 grid with the 19 items (6x)', fill='white', font=font)
    board.alpha_composite(big, (20, 26))
    names = [('fsp', 'Fission power 2x2'), ('rover_pressurized', 'Press. rover 2x2'), ('gpr', 'Radar 1x2'),
             ('hga', 'High-gain ant. 1x2'), ('battery', 'Battery'), ('water', 'Water tank'), ('solar', 'Solar 2x1'),
             ('eclss', 'Life support 2x1'), ('shelter', 'Shelter 2x1'), ('crate', 'Supply crate'),
             ('rover_open', 'Open rover 2x1'), ('suits', 'EVA suits'), ('field_kit', 'Field kit/drill'),
             ('sample_containers', 'Sample tubes'), ('spectrometer', 'Spectrometer'), ('met', 'Weather st.'),
             ('medkit', 'Medical kit'), ('uhf', 'UHF radio'), ('spares', 'Spare parts')]
    for i, (k, n) in enumerate(names):
        d.text((112 * S + 40, 26 + i * 24), n, fill='white', font=font)
    y = 26 + 80 * S + 14
    d.text((20, y), 'Actual size 1x and 2x:', fill='white', font=font)
    board.alpha_composite(grid, (20, y + 22)); board.alpha_composite(grid.resize((224, 160), Image.NEAREST), (150, y + 22))
    board = board.crop((0, 0, W, y + 22 + 160 + 12))
    board.save('preview_items.png'); print('ok', board.size)
