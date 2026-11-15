"""MARGIN — detail animations: tiles, grid items, adjacency icons, screen effects."""
from PIL import Image
import math, random
from make_res_icons import PAL, rgba
from make_item_icons import C, fsp, eclss, battery, uhf, met, spectrometer, solar
import make_map_tiles as mt
from make_eva_events import col, BAYER
from anim_core import add

def recolor(c, mp):
    for y in range(c.h):
        for x in range(c.w):
            if c.g[y][x] in mp: c.g[y][x] = mp[c.g[y][x]]
    return c

# ---------------- tiles ----------------
def tiles():
    fr = []
    for k in range(4):
        c = mt.target()
        for x, y in ((6, 5), (6, 7), (7, 6), (5, 4)): c.P(x, y, 'L' if (x + y) % 2 else 'O')   # clears the shine
        c.P(5, 6, 'L')
        pts = {0: [(5, 6)], 1: [(5, 6), (6, 5), (4, 6), (6, 7), (5, 7)], 2: [(5, 6), (5, 4), (5, 8), (3, 6), (7, 6)], 3: [(5, 6)]}[k]
        for i, (x, y) in enumerate(pts): c.P(x, y, 'W' if i == 0 else 'u')
        fr.append(c.img())
    add('map', 'tile_target', 'sparkle', fr, fps=6, durations=[6.0, 1.0, 1.0, 1.0],
        note='target tile with shine; use as an AnimatedSprite2D on top of the TileMap or as an animated tile in the TileSet')
    a = mt.lander(); b = mt.lander(); b.R(11, 6, 12, 6, 'R')
    add('map', 'tile_lander', 'blink', [a.img(), b.img()], fps=2, note='landing light blinking')
    fr = []
    for k in range(4):
        im = Image.new('RGBA', (16, 16))
        for y in range(16):
            for x in range(16):
                c = rgba(PAL['D'][1]) if (x + y + k) % 2 == 0 and (x * 3 + y * 5 + k * 2) % 7 == 0 else rgba(PAL['K'][1])
                im.putpixel((x, y), c[:3] + (225,))
        fr.append(im)
    add('map', 'map_fog', 'shimmer', fr, fps=3, note='fog moving slowly; when revealing, fade with modulate.a')

# ---------------- items ----------------
def items():
    seq = ['N', 'Y', 'N', 'O']
    add('items', 'item_fsp', 'active', [recolor(fsp(), {'N': k}).img() for k in seq], fps=4,
        note='reactor on: pulsing heat glow')
    fr = []
    for k in range(4):
        c = eclss()
        c.disc(8, 8, 3, 'G'); c.P(8, 8, 'W')
        if k % 2 == 0: c.L(5, 5, 11, 11, 'g'); c.L(5, 11, 11, 5, 'g')
        else: c.R(8, 4, 8, 12, 'g'); c.R(4, 8, 12, 8, 'g')
        c.P(8, 8, 'W'); c.P(26, 10, 'V' if k < 2 else 'G')
        fr.append(c.img())
    add('items', 'item_eclss', 'active', fr, fps=8, note='life support: fan spinning, green light')
    fr = []
    for k in range(4):
        c = battery()
        for i, y in enumerate((11, 9, 7, 5)): c.R(6, y, 9, y, 'V' if i <= k else 'G')
        fr.append(c.img())
    add('items', 'item_battery', 'charging', fr, fps=3, note='battery charging (bars filling up)')
    fr = []
    for k in range(3):
        c = uhf()
        for x, y in ((13, 2), (14, 3), (13, 4), (12, 1), (15, 4)): c.P(x, y, '.')
        if k >= 1: c.P(13, 2, 'u'); c.P(13, 4, 'u')
        if k >= 2: c.P(14, 1, 'u'); c.P(15, 3, 'u'); c.P(14, 5, 'u')
        c.P(6, 10, 'V' if k != 1 else 'G')
        fr.append(c.img())
    add('items', 'item_uhf', 'active', fr, fps=4, note='radio transmitting')
    fr = []
    for k in range(4):
        c = met()
        c.R(2, 2, 13, 3, '.'); c.R(7, 1, 8, 2, 'Y')
        arm = (5, 3, 1, 3)[k]
        c.R(7 - arm, 3, 8 + arm, 3, 'g')
        c.R(7 - arm - 1, 2, 7 - arm, 3, 'W'); c.R(8 + arm, 2, 8 + arm + 1, 3, 'W' if k != 2 else 'g')
        fr.append(c.img())
    add('items', 'item_met', 'active', fr, fps=8, note='anemometer spinning')
    fr = []
    hs = [(2, 4, 3, 5, 2, 3), (3, 3, 4, 4, 3, 2), (2, 5, 2, 3, 4, 3), (4, 4, 3, 5, 2, 4)]
    for k in range(4):
        c = spectrometer()
        c.R(4, 3, 11, 8, 'K')
        for x, h, colr in zip(range(5, 11), hs[k], ('U', 'V', 'V', 'Y', 'N', 'X')): c.R(x, 8 - h, x, 7, colr)
        fr.append(c.img())
    add('items', 'item_spectrometer', 'active', fr, fps=6, note='spectrum changing on the screen')
    fr = []
    for k in range(5):
        c = solar()
        if k < 4:
            for y in range(3, 10):
                for x in range(2, 30):
                    if c.g[y][x] == 'U' and abs((x - y) - (k * 8 - 4)) <= 1: c.g[y][x] = 'u'
        fr.append(c.img())
    add('items', 'item_solar', 'shine', fr, fps=8, durations=[1.0, 1.0, 1.0, 1.0, 12.0], note='reflection sweeping across the panel')

# ---------------- adjacency icons ----------------
def adj_heat(k):
    c = C(16, 16)
    tip = (7, 8, 7, 6)[k]; top = (2, 3, 1, 2)[k]
    for y in range(top, 15):
        t = (y - top) / (14 - top)
        hw = 5.2 * math.sin(min(1.0, t * 1.15) * math.pi * 0.62) if t < 0.86 else 5.2 * (1 - (t - 0.86) * 2.5)
        cx = tip + (7.5 - tip) * t
        for x in range(16):
            dx = abs(x - cx)
            if dx <= hw: c.P(x, y, 'N')
            if dx <= hw * 0.6 and t > 0.35: c.P(x, y, 'Y')
            if dx <= hw * 0.28 and t > 0.6: c.P(x, y, 'W')
    return c.outline().img()

def adj_contam(k):
    c = C(16, 16)
    c.disc(7.5, 8.5, 4.5, 'B'); c.P(6, 6, 'S'); c.P(5, 7, 'S'); c.P(9, 11, 'R'); c.P(10, 10, 'R')
    pts = [((2, 3), (13, 4), (12, 13)), ((3, 12), (13, 2), (2, 5))][k]
    for x, y in pts: c.R(x, y, x + 1, y + 1, 'B')
    c.outline()
    return c.img()

def adj_shield(k):
    c = C(16, 16)
    for y in range(2, 14):
        hw = 5 if y < 9 else 5 - (y - 8)
        c.R(round(7.5 - hw), y, round(7.5 + hw), y, 'U')
    c.R(3, 2, 12, 2, 'u'); c.R(3, 2, 3, 8, 'u')
    c.R(7, 4, 8, 11, 'u')
    if k: c.P(4, 3, 'W'); c.P(5, 4, 'W'); c.P(4, 4, 'W'); c.P(10, 3, 'W')
    return c.outline().img()

def adjacency():
    add('ui', 'adj_heat', 'pulse', [adj_heat(k) for k in range(4)], fps=6, note='adjacency rule: HEAT (orange), rising waves')
    add('ui', 'adj_contam', 'pulse', [adj_contam(k) for k in range(2)], fps=3, note='adjacency rule: CONTAMINATION (brown)')
    add('ui', 'adj_shield', 'pulse', [adj_shield(k) for k in range(2)], fps=3, note='adjacency rule: SHIELDING (blue)')

# ---------------- screen effects ----------------
def fx():
    rnd = random.Random(77)
    streaks = [(rnd.randrange(320), rnd.randrange(180), rnd.randrange(3, 8), rnd.random() < 0.6) for _ in range(140)]
    fr = []
    for t in range(8):
        im = Image.new('RGBA', (320, 180))
        haze = rgba(PAL['O'][1])[:3] + (70,)
        for y in range(180):
            for x in range(320):
                if (BAYER[(y + t) % 4][(x + t * 2) % 4] < 6): im.putpixel((x, y), haze)
        for x0, y0, l, light in streaks:
            x = (x0 - t * 40) % 320; y = (y0 + t * 15) % 180
            k = rgba(PAL['L' if light else 'S'][1])[:3] + (200,)
            for i in range(l):
                xx, yy = (x - i) % 320, (y + i // 3) % 180
                im.putpixel((xx, yy), k)
        fr.append(im)
    add('fx', 'fx_dust_overlay', 'loop', fr, fps=10,
        note='semi-transparent dust over the whole screen (320x180) during a storm; continuous loop')
    fr = []
    for k in range(2):
        im = Image.new('RGBA', (320, 180))
        th = (6, 9)[k]
        red = rgba(PAL['X'][1])[:3]
        for y in range(180):
            for x in range(320):
                d = min(x, y, 319 - x, 179 - y)
                if d < th and BAYER[y % 4][x % 4] < (16 - d * 16 // th):
                    im.putpixel((x, y), red + (150,))
        fr.append(im)
    add('fx', 'fx_alert_vignette', 'pulse', fr, fps=3, note='pulsing red border (critical alert); on top of everything')
    fr = []
    for k in range(6):
        c = C(16, 16); r = (1, 3, 5, 6, 4, 2)[k]
        kk = 'W' if k < 3 else 'L'
        for i in range(1, r + 1):
            c.P(7 + i, 7, kk); c.P(7 - i, 7, kk); c.P(7, 7 + i, kk); c.P(7, 7 - i, kk)
        if 1 <= k <= 4:
            d = r // 2
            for sx, sy in ((1, 1), (1, -1), (-1, 1), (-1, -1)): c.P(7 + sx * d, 7 + sy * d, 'u')
        c.P(7, 7, 'W' if k < 5 else 'u')
        fr.append(c.img())
    add('fx', 'fx_sparkle', 'burst', fr, fps=12, loop=False, note='success sparkle (sample collected, objective met); NOT a loop')

def register():
    tiles(); items(); adjacency(); fx()
