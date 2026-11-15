"""MARGIN — EVA astronauts (16x16, 2 frames) and 160x90 event illustrations
(pixel art made in code, with AI: Claude)."""
from PIL import Image, ImageDraw, ImageFont
import math, os, random, sys
from make_res_icons import PAL, rgba
from make_item_icons import C

STRIPE = {'vega': 'X', 'okoye': 'Y', 'tanaka': 'N', 'duarte': 'V'}

def eva(cid, frame):  # side view, facing right (flip in Godot)
    c = C(16, 16); st = STRIPE[cid]
    c.R(3, 5, 5, 10, 'g'); c.R(3, 10, 5, 10, 'G'); c.R(3, 5, 3, 10, 'G')      # backpack
    c.disc(8.5, 4, 3, 'W'); c.P(6, 3, 'g'); c.P(6, 4, 'g')                    # helmet
    c.R(9, 3, 11, 5, 'S'); c.P(10, 3, 'L'); c.P(11, 5, 'O')                   # gold visor
    c.P(8, 1, st)                                                              # light/identification
    c.R(6, 7, 10, 11, 'W'); c.R(10, 7, 10, 11, 'g'); c.R(6, 9, 10, 9, st)    # torso + stripe
    if frame == 0:
        c.R(10, 8, 12, 9, 'W'); c.P(12, 9, 'g'); c.P(10, 8, st)               # arm forward
        c.R(5, 12, 6, 13, 'W'); c.R(4, 14, 6, 14, 'G')                        # back leg
        c.R(9, 12, 10, 13, 'W'); c.R(9, 14, 11, 14, 'G')                      # front leg
    else:
        c.R(9, 8, 10, 11, 'W'); c.P(9, 8, st); c.P(10, 11, 'g')               # arm against the body
        c.R(7, 12, 9, 13, 'W'); c.R(8, 12, 8, 13, 'g'); c.R(6, 14, 10, 14, 'G')
    return c.outline()

# ---------------- illustrations ----------------
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

def col(k): return rgba(PAL[k][1])

def grad(im, y0, y1, bands):
    """bands: list of colors from top to bottom; blended with ordered dithering."""
    n = len(bands) - 1
    for y in range(y0, y1):
        t = (y - y0) / max(1, (y1 - y0 - 1)) * n
        i = min(int(t), n - 1); f = t - i
        for x in range(im.width):
            im.putpixel((x, y), col(bands[i + 1] if f * 16 > BAYER[y % 4][x % 4] else bands[i]))

def dither_fill(im, mask_fn, k, ratio):
    for y in range(im.height):
        for x in range(im.width):
            if mask_fn(x, y) and ratio * 16 > BAYER[y % 4][x % 4]: im.putpixel((x, y), col(k))

def ridge(im, base_y, amp, freqs, k, seed, y_end=90):
    rnd = random.Random(seed); ph = [rnd.random() * 6.28 for _ in freqs]
    for x in range(im.width):
        h = base_y + sum(amp / (i + 1) * math.sin(x * f + p) for i, (f, p) in enumerate(zip(freqs, ph)))
        for y in range(max(0, round(h)), y_end): im.putpixel((x, y), col(k))

def specks(im, y0, y1, ks, n, seed):
    rnd = random.Random(seed)
    for _ in range(n):
        x, y = rnd.randrange(im.width), rnd.randrange(y0, y1); im.putpixel((x, y), col(rnd.choice(ks)))

def disc_on(im, cx, cy, r, k):
    for y in range(max(0, int(cy - r - 1)), min(im.height, int(cy + r + 2))):
        for x in range(max(0, int(cx - r - 1)), min(im.width, int(cx + r + 2))):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r + r * 0.8: im.putpixel((x, y), col(k))

def line_on(im, x0, y0, x1, y1, k):
    c = C(im.width, im.height); c.L(x0, y0, x1, y1, k)
    for y in range(c.h):
        for x in range(c.w):
            if c.g[y][x] != '.': im.putpixel((x, y), col(k))

def hab(c, x0, y0):  # small habitat/lander (side view) on canvas C
    c.R(x0 + 2, y0 + 8, x0 + 3, y0 + 12, 'G'); c.R(x0 + 14, y0 + 8, x0 + 15, y0 + 12, 'G')
    c.R(x0, y0 + 12, x0 + 4, y0 + 12, 'g'); c.R(x0 + 13, y0 + 12, x0 + 17, y0 + 12, 'g')
    c.R(x0 + 1, y0 + 3, x0 + 16, y0 + 9, 'W'); c.R(x0 + 3, y0 + 1, x0 + 14, y0 + 2, 'W')
    c.R(x0 + 1, y0 + 9, x0 + 16, y0 + 9, 'g'); c.R(x0 + 16, y0 + 3, x0 + 16, y0 + 9, 'g')
    c.R(x0 + 7, y0 + 5, x0 + 9, y0 + 9, 'G'); c.R(x0 + 7, y0 + 5, x0 + 9, y0 + 5, 'U')
    c.P(x0 + 13, y0 + 4, 'X')

def ev_dust(t=0):
    im = Image.new('RGBA', (160, 90)); grad(im, 0, 62, ['S', 'S', 'O'])
    disc_on(im, 38, 18, 6, 'L'); disc_on(im, 38, 18, 4, 'W')
    ridge(im, 54, 3, [0.05, 0.13], 'O', 1); ridge(im, 61, 1.5, [0.08, 0.2], 'S', 2)
    specks(im, 62, 90, ['O', 'L', 'O'], 120, 3)
    for x, y, w in ((12, 78, 6), (120, 82, 8), (70, 74, 4), (98, 68, 3)):
        for i in range(w): im.putpixel((x + i, y), col('R')); im.putpixel((x + i, y - 1), col('O'))
    # wall of dust arriving from the right
    rnd = random.Random(7)
    blobs = [(rnd.uniform(78, 175), rnd.uniform(4, 70), rnd.uniform(9, 20)) for _ in range(38)]
    blobs.sort(key=lambda b: b[0] + b[1] * 0.3)
    for bx, by, r in blobs:
        ph = 2 * math.pi * t / 6
        bx, by = bx + (math.sin(ph + by) - math.sin(by)) * 1.2, by + (math.cos(ph + bx) - math.cos(bx)) * 0.8
        disc_on(im, bx, by, r, 'R'); disc_on(im, bx - r * 0.25, by - r * 0.25, r * 0.78, 'O')
        disc_on(im, bx - r * 0.45, by - r * 0.45, r * 0.35, 'S')
    dither_fill(im, lambda x, y: x > 60 and y > 30, 'O', 0.35)
    dither_fill(im, lambda x, y: x > 50, 'R', 0.12)
    c = C(160, 90); hab(c, 14, 51)
    sp = Image.new('RGBA', (160, 90)); sp.alpha_composite(c.outline().img())
    for i, (cid, f) in enumerate((('vega', 0), ('okoye', 1))):
        e = eva(cid, (f + t) % 2).img().transpose(Image.Transpose.FLIP_LEFT_RIGHT); sp.alpha_composite(e, (44 + i * 12, 52))
    im.alpha_composite(sp)
    for _ in range(70):                                   # dust gusts
        x, y = rnd.randrange(40, 160), rnd.randrange(0, 90); l = rnd.randrange(3, 7)
        x = 40 + (x - 40 - t * 20) % 120; y = (y + t * 15) % 90
        line_on(im, x, y, x - l, y + l // 3, 'L' if rnd.random() < 0.6 else 'S')
    return im

def ev_spe(t=0):
    im = Image.new('RGBA', (160, 90)); grad(im, 0, 64, ['D', 'D', 'R', 'O'])
    for r, k in ((15, 'N'), (11, 'Y'), (8, 'L'), (6, 'W')): disc_on(im, 26, 18, r if k != 'N' else 13, k)
    for a in range(0, 360, 30):                            # coroa
        ra = math.radians(a + (15 if t % 2 else 0)); L2 = 18 + (t % 2)
        line_on(im, round(26 + 14 * math.cos(ra)), round(18 + 14 * math.sin(ra)),
                round(26 + L2 * math.cos(ra)), round(18 + L2 * math.sin(ra)), 'N')
    ridge(im, 56, 3, [0.04, 0.11], 'R', 4); ridge(im, 63, 1.5, [0.07, 0.19], 'O', 5)
    specks(im, 64, 90, ['R', 'S'], 110, 6)
    c = C(160, 90)
    # shelter (blue = shielding)
    c.R(98, 56, 135, 56, 'W'); c.R(96, 57, 137, 69, 'g'); c.R(96, 57, 137, 57, 'W'); c.R(137, 57, 137, 69, 'G')
    for x in (100, 101, 131, 132): c.R(x, 56, x, 68, 'U')
    c.R(114, 61, 118, 69, 'G'); c.R(115, 62, 117, 63, 'u'); c.R(108, 60, 109, 61, 'Y'); c.R(123, 60, 124, 61, 'Y')
    sp = c.outline().img()
    for i, (cid, f) in enumerate((('tanaka', 0), ('duarte', 1), ('vega', 0))):
        sp.alpha_composite(eva(cid, (f + t) % 2).img(), (62 + i * 14, 56 + (i % 2)))
    im.alpha_composite(sp)
    rnd = random.Random(11)                                # rain of particles
    for _ in range(46):
        x, y = rnd.randrange(30, 175), rnd.randrange(-10, 70); l = rnd.randrange(5, 11)
        y = -10 + (y + 10 + t * 20) % 80
        line_on(im, x, y, x - l // 2, y + l, rnd.choice(['Y', 'W', 'Y', 'N']))
    return im

def ev_failure(t=0):
    im = Image.new('RGBA', (160, 90)); grad(im, 0, 58, ['L', 'S'])
    disc_on(im, 110, 16, 5, 'W')
    ridge(im, 52, 3, [0.05, 0.12], 'O', 8); ridge(im, 60, 1.5, [0.09, 0.21], 'S', 9)
    specks(im, 60, 90, ['O', 'L'], 120, 10)
    c = C(160, 90)
    # large pressurized rover, tilted back (rear wheel loose)
    for y in range(34, 64):
        tilt = (y - 34) * 0
    body = [(26, 40, 104, 62)]
    c.R(30, 36, 100, 37, 'W'); c.R(26, 38, 104, 60, 'W'); c.R(26, 60, 104, 61, 'g'); c.R(104, 38, 104, 61, 'g')
    c.R(86, 40, 102, 49, 'U'); c.R(88, 41, 100, 43, 'u')                      # windshield
    for x0 in (34, 48): c.R(x0, 42, x0 + 7, 47, 'U'); c.R(x0, 42, x0 + 2, 43, 'u')
    c.R(62, 40, 72, 58, 'g'); c.R(65, 43, 69, 46, 'u')                        # hatch
    c.R(26, 53, 104, 54, 'U')                                                 # shielding stripe
    c.L(92, 36, 92, 28, 'G'); c.R(88, 27, 96, 27, 'g')                        # antenna
    for cx in (60, 92):                                                       # rodas no lugar
        c.disc(cx, 66, 7, 'G'); c.ring(cx, 66, 7, 'K'); c.disc(cx, 66, 2, 'g')
    c.R(30, 62, 40, 66, 'G'); c.R(32, 64, 36, 66, 'K')                        # empty hub (wheel came off)
    c.disc(18, 76, 7, 'G'); c.ring(18, 76, 7, 'K'); c.disc(18, 76, 2, 'g')   # loose wheel on the ground
    c.L(13, 71, 23, 81, 'K')
    sp = c.outline().img()
    e = eva('tanaka', 1).img().transpose(Image.Transpose.FLIP_LEFT_RIGHT); sp.alpha_composite(e, (118, 58))
    im.alpha_composite(sp)
    wy = -1 if t % 2 else 0
    line_on(im, 117, 66 + wy, 113, 62 + wy, 'g'); line_on(im, 113, 62 + wy, 112, 61 + wy, 'G')   # wrench
    rnd = random.Random(13)                                                   # smoke and sparks
    for i in range(8):
        j = (i + t / 6) % 8
        disc_on(im, 30 - j * 2.2 + rnd.uniform(-1, 1), 62 - j * 5, 2 + j * 0.6, 'G' if (i + t) % 2 else 'g')
    rs = random.Random(13 + t * 7) if t else rnd
    for _ in range(14 if t % 3 != 2 else 4):
        x, y = 35 + rs.randrange(-8, 9), 63 + rs.randrange(-6, 5)
        im.putpixel((x, y), col(rs.choice(['Y', 'N', 'W'])))
    tri = C(160, 90)                                                          # warning
    for i in range(9): tri.R(146 - i // 2 * 1 - i // 2, 6 + i, 146 + i // 2 + i // 2, 6 + i, 'Y' if t % 3 != 2 else 'L')
    tri.R(146, 8, 146, 11, 'K'); tri.P(146, 13, 'K')
    im.alpha_composite(tri.outline().img())
    return im

if __name__ == '__main__':
    os.makedirs('out/crew', exist_ok=True); os.makedirs('out/events', exist_ok=True)
    frames = {}
    for cid in STRIPE:
        for f in (0, 1):
            im = eva(cid, f).img(); im.save(f'out/crew/eva_{cid}_{f}.png'); frames[(cid, f)] = im
    sheet = Image.new('RGBA', (32, 64))
    for j, cid in enumerate(STRIPE):
        for f in (0, 1): sheet.paste(frames[(cid, f)], (16 * f, 16 * j))
    sheet.save('out/crew/eva_sheet.png')
    evs = {'event_dust_storm': ev_dust(), 'event_solar_particle_event': ev_spe(), 'event_equipment_failure': ev_failure()}
    for k, im in evs.items(): im.save(f'out/events/{k}.png')

    font = ImageFont.load_default(size=13)
    board = Image.new('RGBA', (1000, 1400), rgba('#2a2430')); d = ImageDraw.Draw(board)
    d.text((20, 4), 'EVA astronauts 16x16 (6x), frames 0 and 1, on the ground', fill='white', font=font)
    tile = Image.open(sys.argv[1]) if len(sys.argv) > 1 else None
    x = 20
    for cid in STRIPE:
        for f in (0, 1):
            bg = tile.copy() if tile else Image.new('RGBA', (16, 16), col('S'))
            bg.alpha_composite(frames[(cid, f)]); board.alpha_composite(bg.resize((96, 96), Image.NEAREST), (x, 24)); x += 104
        x += 16
    y = 140
    for k, im in evs.items():
        d.text((20, y), f'{k} (160x90, 3x)', fill='white', font=font)
        board.alpha_composite(im.resize((480, 270), Image.NEAREST), (20, y + 20))
        y += 300
    board = board.crop((0, 0, 1000, y))
    board.save('preview_eva_events.png'); print('ok')
