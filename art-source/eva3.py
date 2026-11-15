"""MARGIN — EVA astronaut v3 (16x16, side view, facing right), drawn by hand pixel by pixel.
Rules from the pixel-art-sprites skill: silhouette readable at 1x, arm that breaks the silhouette, top-left light,
selective 1 px outline, 4 walking frames (contact/passing), sub-pixel idle, anticipation when collecting.
Kept only as history: the team chose the original astronaut."""
from make_item_icons import C

STRIPE = {'vega': 'X', 'okoye': 'Y', 'tanaka': 'N', 'duarte': 'V'}

# body WITHOUT outer outline (the outline is automatic). s = crew member's stripe.
BODY = [
    "................",   # 0
    ".......WWW......",   # 1
    "......WWWWW.....",   # 2
    ".....WWWWRRR....",   # 3  dark reflective visor
    ".WWgKWWWRRSR....",   # 4  backpack (PLSS) + helmet
    ".WggKWWWRRRR....",   # 5
    ".gggKWWWWWWg....",   # 6
    ".gggKGGGGGGG....",   # 7  neck ring
    ".gggKWWWWWWg....",   # 8  torso
    ".gggKssssssg....",   # 9  stripe
    ".GGGKWWWWWWg....",   # 10
    ".....ggggggg....",   # 11 waist
]

ARMS = {  # front arm pixels: (x, y_rel, color) — y relative to the top of the body (adds dy)
    'down': [(7, 8, 'g'), (7, 9, 'g'), (7, 10, 'g'), (8, 8, 'W'), (9, 8, 'W'), (8, 9, 'W'), (9, 9, 'W'),
             (8, 10, 'W'), (9, 10, 'W'), (8, 11, 'G'), (9, 11, 'G')],
    'mid':  [(8, 8, 'g'), (8, 9, 'g'), (8, 10, 'g'), (9, 8, 'W'), (10, 8, 'W'), (9, 9, 'W'), (10, 9, 'W'),
             (9, 10, 'W'), (10, 10, 'W'), (9, 11, 'G'), (10, 11, 'G')],
    'fwd':  [(7, 8, 'g'), (8, 8, 'W'), (9, 8, 'W'), (8, 9, 'g'), (9, 9, 'W'), (10, 9, 'W'),
             (10, 10, 'W'), (11, 10, 'W'), (12, 10, 'W'), (12, 9, 'W'), (13, 10, 'G'), (13, 9, 'G')],
    'back': [(9, 8, 'g'), (7, 8, 'W'), (8, 8, 'W'), (8, 9, 'g'), (6, 9, 'W'), (7, 9, 'W'),
             (7, 10, 'g'), (5, 10, 'W'), (6, 10, 'W'), (5, 11, 'G'), (6, 11, 'G')],
    'up1':  [(8, 8, 'g'), (9, 8, 'W'), (10, 8, 'W'), (10, 7, 'W'), (11, 7, 'W'), (11, 6, 'W'), (12, 6, 'W'),
             (12, 5, 'W'), (12, 4, 'G'), (13, 4, 'G'), (13, 5, 'G')],
    'up2':  [(8, 8, 'g'), (9, 8, 'W'), (10, 8, 'W'), (10, 7, 'W'), (11, 7, 'W'), (12, 7, 'W'), (12, 6, 'W'),
             (13, 6, 'W'), (13, 5, 'G'), (14, 5, 'G'), (14, 4, 'G')],
    'reach': [(8, 8, 'g'), (9, 8, 'W'), (10, 8, 'W'), (9, 9, 'g'), (10, 9, 'W'), (11, 9, 'W'),
              (11, 10, 'W'), (12, 10, 'W'), (12, 11, 'G'), (13, 11, 'G')],
    'raise': [(8, 8, 'g'), (9, 8, 'W'), (10, 8, 'W'), (10, 7, 'W'), (11, 7, 'W'), (11, 6, 'G'), (12, 6, 'G')],
}
FAR_ARM = {'fwd': [(11, 9, 'G'), (12, 10, 'G')], 'back': [(4, 11, 'G')], None: []}

LEGS = {  # far/near: {row: (x0, x1)}, boot: (row, x0, x1). Absolute rows (ground = 14).
    'stand':   dict(far={12: (5, 6), 13: (5, 6)}, fboot=(14, 5, 7), near={12: (9, 10), 13: (9, 10)}, nboot=(14, 9, 11)),
    'contactA': dict(far={12: (5, 6), 13: (4, 5)}, fboot=(14, 3, 5), near={12: (9, 10), 13: (10, 11)}, nboot=(14, 11, 13)),
    'passA':   dict(far={11: (6, 7), 12: (5, 6)}, fboot=(13, 4, 6), near={11: (8, 9), 12: (8, 9), 13: (8, 9)}, nboot=(14, 8, 10)),
    'contactB': dict(far={12: (9, 10), 13: (10, 11)}, fboot=(14, 11, 13), near={12: (5, 6), 13: (4, 5)}, nboot=(14, 3, 5)),
    'passB':   dict(far={11: (7, 8), 12: (7, 8), 13: (7, 8)}, fboot=(14, 7, 9), near={11: (9, 10), 12: (10, 11)}, nboot=(13, 10, 12)),
    'kneel':   dict(far={13: (4, 6)}, fboot=(14, 2, 5), near={12: (9, 11), 13: (11, 12)}, nboot=(14, 11, 13)),
}

def make(cid, dy=0, legs='stand', arm='down', far_arm=None, glint=0, breath=0, light=None, tool=None, dust=0):
    st = STRIPE[cid]; c = C(16, 16); L = LEGS[legs]
    # back leg (darker)
    for y, (x0, x1) in L['far'].items(): c.R(x0, y, x1, y, 'g')
    y, x0, x1 = L['fboot']; c.R(x0, y, x1, y, 'G')
    for (x, y, k) in FAR_ARM[far_arm]: c.P(x, y + dy, k)
    # body
    for yy, row in enumerate(BODY):
        for xx, ch in enumerate(row):
            if ch != '.': c.P(xx, yy + dy, st if ch == 's' else ch)
    # visor: shine (sub-pixel)
    gx, gy = ((10, 4), (9, 4), (10, 3))[glint % 3]; c.P(gx, gy + dy, 'S')
    if glint: c.P(gx - 1 if glint == 2 else gx, gy + dy - (1 if glint == 2 else 0), 'L')
    # breathing (sub-pixel): shoulder lightens, base of the torso darkens
    if breath: c.P(11, 8 + dy, 'W'); c.P(5, 10 + dy, 'g'); c.P(11, 6 + dy, 'W' if breath == 2 else 'g')
    if light: c.P(2, 9 + dy, light)                                       # backpack light
    c.P(7, 1 + dy, st)                                                    # identification light on the helmet
    # front leg (white, shadow on the right)
    for y, (x0, x1) in L['near'].items(): c.R(x0, y, x1, y, 'W'); c.P(x1, y, 'g')
    y, x0, x1 = L['nboot']; c.R(x0, y, x1, y, 'G')
    # front arm
    for (x, y, k) in ARMS[arm]: c.P(x, y + dy, k)
    # tool (geological hammer)
    if tool == 'low':   c.R(14, 10 + dy, 14, 13, 'g'); c.R(13, 13, 15, 13, 'G')
    if tool == 'up':    c.R(12, 3 + dy, 12, 5 + dy, 'g'); c.R(11, 2 + dy, 13, 2 + dy, 'G')
    if tool == 'smear': c.R(14, 6 + dy, 14, 13, 'W'); c.R(13, 13, 15, 13, 'G'); c.R(15, 7 + dy, 15, 11 + dy, 'L')
    if tool == 'down':  c.R(14, 12, 14, 13, 'g'); c.R(13, 14, 15, 14, 'G')
    c.outline()
    for x, y, k in [(15, 13, 'L'), (12, 15, 'S'), (15, 11, 'S'), (11, 15, 'L'), (15, 15, 'S'), (13, 12, 'L')][:dust]:
        if c.g[y][x] in '.K': c.P(x, y, k)
    return c.img()

def walk(cid):
    return [make(cid, 0, 'contactA', 'back', 'fwd'), make(cid, -1, 'passA', 'mid'),
            make(cid, 0, 'contactB', 'fwd', 'back'), make(cid, -1, 'passB', 'mid')]

def idle(cid):
    return [make(cid), make(cid, breath=1), make(cid, breath=2, glint=1, light='V'), make(cid, breath=1, glint=2)]

def work(cid):  # anticipation -> strike -> impact (held) -> recovery
    k = dict(dy=1, legs='kneel')
    return [make(cid, **k, arm='reach', tool='low'),
            make(cid, **k, arm='raise', tool='up'),
            make(cid, **k, arm='reach', tool='smear'),
            make(cid, **k, arm='reach', tool='down', dust=6),
            make(cid, **k, arm='reach', tool='down', dust=3),
            make(cid, **k, arm='reach', tool='low', dust=1)]
WORK_DUR = [2.0, 2.5, 0.6, 2.0, 1.5, 1.5]

def wave(cid):
    return [make(cid, arm='up1'), make(cid, arm='up2', breath=1), make(cid, arm='up1'), make(cid, arm='up2', breath=1)]
