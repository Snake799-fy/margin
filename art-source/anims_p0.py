"""MARGIN — essential animations: EVA astronauts, rovers on the map, map markers."""
from make_item_icons import C
from anim_core import add

STRIPE = {'vega': 'X', 'okoye': 'Y', 'tanaka': 'N', 'duarte': 'V'}

# legs: (x of the near leg, x of the far leg) — near = white, far = shaded
LEGS = {
    'stand':    dict(near=(8, 9), far=(6, 7), boot_near=(8, 10), boot_far=(5, 7), h=2),
    'contactR': dict(near=(9, 10), far=(5, 6), boot_near=(9, 11), boot_far=(4, 6), h=2),
    'contactL': dict(near=(5, 6), far=(9, 10), boot_near=(4, 6), boot_far=(9, 11), h=2),
    'pass':     dict(near=(7, 8), far=(8, 9), boot_near=(7, 9), boot_far=(8, 10), h=2),
    'crouch':   dict(near=(9, 10), far=(5, 6), boot_near=(9, 11), boot_far=(4, 6), h=1),
}

def eva(cid, legs='stand', dy=0, arm='down', glint=0, light='on', tool=None, dust=0, breath=0):
    st = STRIPE[cid]; c = C(16, 16); L = LEGS[legs]
    def P(x, y, k): c.P(x, y + dy, k)
    def R(x0, y0, x1, y1, k): c.R(x0, y0 + dy, x1, y1 + dy, k)
    # far leg (behind)
    fx0, fx1 = L['far']; c.R(fx0, 14 - L['h'], fx1, 13, 'g'); c.R(L['boot_far'][0], 14, L['boot_far'][1], 14, 'G')
    # far arm (only shows behind in "back")
    R(3, 5, 5, 10, 'g'); R(3, 10, 5, 10, 'G'); R(3, 5, 3, 10, 'G')                  # backpack
    c.disc(8.5, 4 + dy, 3, 'W'); P(6, 3, 'g'); P(6, 4, 'g')                         # helmet
    R(9, 3, 11, 5, 'S'); P(11, 5, 'O')                                              # visor
    gx = (10, 11, 9)[glint % 3]; P(gx, 3, 'L')
    if light == 'on': P(8, 1, st)
    else: P(8, 1, 'g')
    R(6, 7, 10, 11, 'W'); R(10, 7, 10, 11, 'g'); R(6, 9, 10, 9, st)                # torso + stripe
    if breath: P(10, 7, 'W'); P(6, 11, 'g')                                        # breathing (sub-pixel)
    if breath == 2: P(7, 2, 'W'); P(6, 3, 'W')
    # near leg
    nx0, nx1 = L['near']; c.R(nx0, 14 - L['h'], nx1, 13, 'W'); c.R(L['boot_near'][0], 14, L['boot_near'][1], 14, 'G')
    if L['h'] == 1: c.R(6, 12, 10, 12, 'W')                                          # crouched hip
    # near arm
    if arm == 'down':  R(8, 8, 8, 10, 'g'); R(9, 8, 10, 11, 'W'); P(9, 8, st); P(10, 11, 'g')
    elif arm == 'fwd': R(10, 8, 12, 9, 'W'); P(12, 9, 'g'); P(10, 8, st)
    elif arm == 'back': R(8, 8, 8, 11, 'g'); R(6, 8, 7, 11, 'W'); P(6, 8, st); P(6, 11, 'g'); R(5, 10, 5, 11, 'g')
    elif arm == 'up1': R(10, 6, 11, 8, 'W'); R(11, 3, 12, 5, 'W'); P(12, 3, 'g'); P(10, 8, st)
    elif arm == 'up2': R(10, 6, 11, 8, 'W'); R(12, 4, 13, 5, 'W'); R(12, 3, 13, 3, 'g'); P(10, 8, st)
    elif arm == 'reach': R(10, 9, 12, 10, 'W'); P(12, 10, 'g'); P(10, 9, st)
    if tool == 'up':   c.R(13, 9 + dy, 13, 12, 'g'); c.P(13, 9 + dy, 'G')
    if tool == 'raised': c.R(12, 1 + dy, 12, 3 + dy, 'g'); c.R(11, 1 + dy, 13, 1 + dy, 'G')
    if tool == 'smear': c.R(13, 4 + dy, 13, 14, 'g'); c.R(14, 5 + dy, 14, 12, 'W'); c.P(13, 14, 'G')
    if tool == 'down': c.R(13, 11 + dy, 13, 14, 'g'); c.P(13, 14, 'G')
    c.outline()
    for i in range(dust):                                                            # collection dust
        for x, y, k in ((14, 13, 'L'), (15, 12, 'S'), (12, 15, 'S'), (15, 14, 'L'))[:dust]:
            c.P(x, y, k)
    return c.img()

def eva_anims():
    for cid in STRIPE:
        add('crew', f'eva_{cid}', 'idle', [eva(cid), eva(cid, breath=1), eva(cid, breath=1, glint=1),
                                         eva(cid, breath=2, glint=2, light='off')],
            fps=4, note='idle: sub-pixel breathing, visor shine, helmet light (~1 s per cycle)')
        add('crew', f'eva_{cid}', 'walk', [
            eva(cid, 'contactR', 0, 'back'), eva(cid, 'pass', -1, 'down'),
            eva(cid, 'contactL', 0, 'fwd'), eva(cid, 'pass', -1, 'down')],
            fps=8, note='side walk (contact/passing, arm opposite the leg) facing right; flip_h for left. '
                        'Move at ~32 px/s so the foot does not "slide"')
        k = dict(legs='crouch', dy=1)
        add('crew', f'eva_{cid}', 'work', [
            eva(cid, **k, arm='reach', tool='up'),                 # crouches and aims
            eva(cid, **k, arm='up1', tool='raised'),               # anticipation: raises the hammer
            eva(cid, **k, arm='reach', tool='smear'),              # quick strike (smear)
            eva(cid, **k, arm='reach', tool='down', dust=4),       # impact (held) with dust
            eva(cid, **k, arm='reach', tool='down', dust=2),       # recovery
            eva(cid, **k, arm='reach', tool='up', dust=1)],
            fps=8, durations=[2.0, 2.5, 0.6, 2.0, 1.5, 1.5],
            note='collecting a sample: anticipation, strike, held impact, recovery')
        add('crew', f'eva_{cid}', 'wave', [eva(cid, arm='up1'), eva(cid, arm='up2', breath=1), eva(cid, arm='up1'),
                                         eva(cid, arm='up2', breath=1)],
            fps=5, note='waving (report, title, landing)')

# ---------------- rovers on the map (top view, facing right) ----------------
def rover_open(f=0, moving=False):
    c = C(16, 16)
    for x0, y0 in ((2, 2), (10, 2), (2, 12), (10, 12)):
        c.R(x0, y0, x0 + 3, y0 + 1, 'G')
        if moving: c.P(x0 + (f % 4), y0, 'K'); c.P(x0 + (f % 4), y0 + 1, 'K')    # tread spinning
    c.box(1, 4, 14, 11, 'g', 'W', 'G')
    c.R(4, 5, 6, 7, 'G'); c.R(4, 8, 6, 10, 'G'); c.P(4, 5, 'g'); c.P(4, 8, 'g')
    c.R(9, 6, 10, 9, 'G'); c.P(9, 7, 'V' if (f % 2 == 0 or not moving) else 'Y')
    c.disc(12.5, 7.5, 1.3, 'W')
    c.outline()
    if moving:
        for x, y, k in (((0, 6, 'L'), (0, 9, 'S')), ((1, 5, 'S'), (0, 10, 'L')), ((0, 7, 'L'), (1, 9, 'L')), ((1, 6, 'S'), (0, 8, 'S')))[f % 4]:
            c.P(x, y, k)
    return c.img()

def rover_press(f=0, moving=False, light=True):
    c = C(16, 16)
    for x0 in (2, 6, 10):
        c.R(x0, 1, x0 + 2, 2, 'G'); c.R(x0, 13, x0 + 2, 14, 'G')
        if moving: c.P(x0 + (f % 3), 1, 'K'); c.P(x0 + (f % 3), 14, 'K')
    c.box(1, 3, 14, 12, 'W', 'W', 'g')
    c.R(1, 3, 14, 3, 'U'); c.R(1, 12, 14, 12, 'U')
    c.R(12, 4, 14, 11, 'U'); c.R(12, 5, 12, 7, 'u')
    c.R(5, 6, 8, 9, 'g'); c.R(6, 7, 7, 8, 'G')
    if light: c.P(14, 4, 'Y'); c.P(14, 11, 'Y')
    c.outline()
    if moving:
        for x, y, k in (((0, 5, 'L'), (0, 10, 'S')), ((1, 6, 'S'), (0, 9, 'L')), ((0, 7, 'L'), (1, 10, 'L')), ((1, 4, 'S'), (0, 8, 'S')))[f % 4]:
            c.P(x, y, k)
    return c.img()

def rover_anims():
    add('map', 'map_rover_open', 'idle', [rover_open(0), rover_open(1)], fps=2, durations=[4.0, 1.0],
        note='idle; console light blinks')
    add('map', 'map_rover_open', 'drive', [rover_open(i, True) for i in range(4)], fps=10, note='driving; dust behind')
    add('map', 'map_rover_pressurized', 'idle', [rover_press(0, light=True), rover_press(0, light=False)], fps=2,
        durations=[3.0, 1.0], note='idle; headlights blink')
    add('map', 'map_rover_pressurized', 'drive', [rover_press(i, True) for i in range(4)], fps=10, note='driving; dust behind')

# ---------------- map markers ----------------
def marker(dy, glow):
    c = C(16, 16)
    c.disc(7.5, 4.5 + dy, 4, 'u'); c.ring(7.5, 4.5 + dy, 4, 'U')
    c.R(6, 3 + dy, 9, 6 + dy, 'W'); c.R(7, 2 + dy, 8, 7 + dy, 'W')
    if glow: c.P(6, 3 + dy, 'u'); c.P(9, 6 + dy, 'u')
    for i, y in enumerate(range(8 + dy, 12 + dy)): c.R(6 + i // 2, y, 9 - i // 2, y, 'u')
    c.P(7, 12 + dy, 'U'); c.P(8, 12 + dy, 'U')
    c.outline()
    w = {0: (5, 10), 1: (6, 9), 2: (7, 8)}[dy]
    c.R(w[0], 15, w[1], 15, 'O')
    return c.img()

def cursor(o, k):
    c = C(16, 16)
    for (x, y, dx, dy) in ((o, o, 1, 1), (15 - o, o, -1, 1), (o, 15 - o, 1, -1), (15 - o, 15 - o, -1, -1)):
        for i in range(4): c.P(x + dx * i, y, k); c.P(x, y + dy * i, k)
    return c.img()

def arrow(dx, k):
    c = C(16, 16)
    for i in range(4):
        c.R(5 + dx + i, 4 + i, 6 + dx + i, 4 + i, k); c.R(5 + dx + i, 11 - i, 6 + dx + i, 11 - i, k)
    return c.outline().img()

def dot(k, r):
    c = C(16, 16)
    if r: c.R(6, 6, 9, 9, k); c.P(6, 6, '.'); c.P(9, 6, '.'); c.P(6, 9, '.'); c.P(9, 9, '.')
    else: c.R(7, 7, 8, 8, k)
    return c.outline().img()

def marker_anims():
    add('map', 'map_marker_target', 'bob', [marker(0, 0), marker(1, 1), marker(2, 1), marker(1, 0)], fps=6, durations=[2.0, 1.0, 2.0, 1.0],
        note='science target floating (loop)')
    add('map', 'map_cursor', 'pulse', [cursor(0, 'W'), cursor(0, 'W'), cursor(1, 'L'), cursor(1, 'L')], fps=6,
        note='selection cursor pulsing')
    add('map', 'map_path_arrow', 'pulse', [arrow(0, 'W'), arrow(1, 'W'), arrow(2, 'L'), arrow(1, 'W')], fps=8,
        note='path tip, points right (rotate with rotation)')
    add('map', 'map_path_dot', 'blink', [dot('W', 0), dot('W', 1), dot('L', 0)], fps=6, durations=[2.0, 1.0, 1.0],
        note='path dots; offset the start frame per cell for a "marching" effect')

def register():
    eva_anims(); rover_anims(); marker_anims()
