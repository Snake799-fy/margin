"""MARGIN — screen animations: title, events, landing."""
from PIL import Image
import math, os, random
from make_res_icons import PAL, rgba
from make_item_icons import C
from make_title import background, logo
from make_eva_events import ev_dust, ev_spe, ev_failure, grad, ridge, disc_on, dither_fill, specks, col, BAYER
from anims_p0 import eva
import eva3
from anim_core import add

def title():
    add('screens', 'title_bg', 'idle', [background(t, crew=False) for t in range(8)], fps=4,
        note='animated title background (stars, sun glow, habitat lights), WITHOUT astronauts: '
             'put title_crew_group or eva_* walking on top (ground at y≈128-142)')
    grp = []
    for t in range(4):
        im = Image.new('RGBA', (64, 16))
        for i, cid in enumerate(('vega', 'okoye', 'tanaka', 'duarte')):
            im.alpha_composite(eva(cid, *({0: ('contactR', 0, 'back'), 1: ('pass', -1, 'down'),
                                           2: ('contactL', 0, 'fwd'), 3: ('pass', -1, 'down')}[(t + i) % 4])), (i * 15, 0))
        grp.append(im)
    add('screens', 'title_crew_group', 'walk', grp, fps=8,
        note='the 4 walking in a row to the right; move x with a Tween (e.g. from -64 to 330 in ~14 s, y=126) and repeat')
    lg = logo().img(); W, H = lg.size
    fr = []
    for s in [None] + list(range(-10, W + H, 12)):
        im = lg.copy()
        if s is not None:
            px = im.load()
            for y in range(H):
                for x in range(W):
                    r, g, b, a = px[x, y]
                    if a and (r, g, b, a) not in (rgba(PAL['K'][1]), rgba(PAL['D'][1])) and s <= x + y <= s + 3:
                        px[x, y] = rgba(PAL['W'][1])
        fr.append(im)
    add('screens', 'logo_margin', 'shine', fr, fps=14, durations=[28.0] + [1.0] * (len(fr) - 1),
        note='shine sweeping across the logo every ~2.5 s')

def events():
    add('events', 'event_dust_storm', 'loop', [ev_dust(t) for t in range(6)], fps=8,
        note='moving wall of dust and gusts; continuous loop')
    add('events', 'event_solar_particle_event', 'loop', [ev_spe(t) for t in range(4)], fps=8,
        note='rain of particles and pulsing corona; continuous loop')
    add('events', 'event_equipment_failure', 'loop', [ev_failure(t) for t in range(6)], fps=6,
        note='rising smoke, sparks and blinking warning; continuous loop')

# ---------------- landing ----------------
def lander(plume=None, lights=True):
    c = C(32, 40)
    for y in range(2, 13):                                          # ascent module
        hw = 3 + (y - 2) * 0.6
        c.R(round(15.5 - hw), y, round(15.5 + hw), y, 'W'); c.P(round(15.5 + hw), y, 'g')
    c.R(14, 6, 17, 7, 'U'); c.P(14, 6, 'u')
    c.R(6, 13, 25, 19, 'g'); c.R(6, 13, 25, 13, 'W'); c.R(6, 19, 25, 19, 'G'); c.R(25, 13, 25, 19, 'G')
    c.R(7, 15, 24, 16, 'Y'); c.R(7, 16, 24, 16, 'S')               # gold thermal blanket
    c.L(8, 19, 3, 26, 'G'); c.L(23, 19, 28, 26, 'G')                # legs
    c.R(1, 27, 5, 27, 'g'); c.R(26, 27, 30, 27, 'g')                # footpads
    c.R(13, 20, 18, 21, 'G'); c.R(14, 22, 17, 22, 'G')              # nozzle
    if lights: c.P(7, 14, 'X'); c.P(24, 14, 'V')
    c.outline()
    if plume is not None:
        rnd = random.Random(plume * 31 + 5)
        L = (11, 14, 12, 15)[plume]
        for y in range(23, 23 + L):
            d = y - 23
            for x in range(32):
                dx = abs(x - 15.5)
                if dx <= 1.2 + d * 0.15 and d < L * 0.45: c.P(x, y, 'W')
                elif dx <= 2.2 + d * 0.22 and d < L * 0.75: c.P(x, y, 'Y')
                elif dx <= 3.0 + d * 0.25 and rnd.random() < 0.85 - d / (L + 2): c.P(x, y, 'N')
    return c.img()

def dust_burst(k, n=7):
    im = Image.new('RGBA', (80, 24))
    rx, ry = 6 + 5.5 * k, 2 + 2.2 * k
    dens = 1.0 - k / n
    for y in range(24):
        for x in range(80):
            dx, dy = (x - 39.5) / rx, (y - 23) / ry
            dd = dx * dx + dy * dy
            if dd <= 1 and dens * 16 * (1.15 - dd * 0.6) > BAYER[y % 4][x % 4]:
                im.putpixel((x, y), col('L' if dd < 0.35 else 'S' if dd < 0.75 else 'O'))
    rnd = random.Random(3)
    for i in range(10):                                             # pebbles flying
        a = rnd.uniform(0.15, 1.0) * (1 if i % 2 else -1); sp = rnd.uniform(4, 7)
        x = 39.5 + a * sp * k * 1.6; y = 22 - sp * k * 0.9 + 0.45 * k * k
        if 0 <= x < 80 and 0 <= y < 24 and k < n - 1: im.putpixel((int(x), int(y)), col('R'))
    return im

def landing_bg():
    im = Image.new('RGBA', (320, 180))
    grad(im, 0, 120, ['O', 'S', 'S', 'L'])
    disc_on(im, 252, 30, 4, 'W'); dither_fill(im, lambda x, y: (x - 252) ** 2 + (y - 30) ** 2 < 100, 'L', 0.5)
    ridge(im, 104, 6, [0.02, 0.06, 0.13], 'O', 41, 180)
    ridge(im, 118, 3, [0.04, 0.1], 'R', 42, 180)
    ridge(im, 128, 2, [0.03, 0.09], 'S', 43, 180)
    specks(im, 128, 180, ['O', 'L', 'O', 'R'], 260, 44)
    for cx, cy, r in ((60, 160, 9), (250, 150, 6), (120, 172, 4)):       # small craters
        for y in range(int(cy - r), int(cy + r) + 1):
            for x in range(int(cx - 2 * r), int(cx + 2 * r) + 1):
                d = ((x - cx) / (2 * r)) ** 2 + ((y - cy) / r) ** 2
                if 0 <= x < 320 and 0 <= y < 180:
                    if d <= 1 and d > 0.6: im.putpixel((x, y), col('L' if y > cy else 'O'))
                    elif d <= 0.6: im.putpixel((x, y), col('O' if y < cy else 'S'))
    return im

def landing():
    add('screens', 'lander', 'descent', [lander(i) for i in range(4)], fps=12,
        note='descending with the engine on; move y with a Tween. Anchor: footpads at y=27 of the frame (32x40)')
    add('screens', 'lander', 'landed', [lander(None, True), lander(None, False)], fps=2, durations=[3.0, 1.0],
        note='landed, lights blinking')
    add('screens', 'touchdown_dust', 'burst', [dust_burst(k) for k in range(7)], fps=12, loop=False,
        note='dust cloud on touchdown (NOT a loop). Center on the ship x, base on the ground; hide when finished')
    os.makedirs('out/ui', exist_ok=True)
    landing_bg().save('out/ui/landing_bg.png')

def register():
    title(); events(); landing()
