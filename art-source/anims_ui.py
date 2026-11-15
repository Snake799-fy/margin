"""MARGIN — UI animations: alerts, critical bar, alert card, resource icons."""
from PIL import Image
from make_res_icons import ICONS, PAL, rgba
from make_item_icons import C
from make_ui_frame import bar_fill, card
from anim_core import add

def grid(name): return [list(r) for r in ICONS[name]]

def to_img(g):
    im = Image.new('RGBA', (16, 16), (0, 0, 0, 0))
    for y, row in enumerate(g):
        for x, ch in enumerate(row):
            if ch != '.': im.putpixel((x, y), rgba(PAL[ch][1]))
    return im

def shine(name, steps, keep='KD'):
    frames = []
    for s in steps:
        g = grid(name)
        if s is not None:
            for y in range(16):
                for x in range(16):
                    if g[y][x] not in '.' + keep and s <= x + y <= s + 1: g[y][x] = 'W'
        frames.append(to_img(g))
    return frames

def res_icons():
    # power: sparks + flash
    fr = []
    for k in range(4):
        g = grid('power')
        if k == 2:
            g = [[('L' if ch == 'Y' else ch) for ch in row] for row in g]
        for x, y in {1: ((13, 3), (2, 13)), 3: ((14, 6), (3, 10))}.get(k, ()):
            g[y][x] = 'W'
        fr.append(to_img(g))
    add('ui', 'res_power', 'idle', fr, fps=8, durations=[8.0, 1.0, 1.0, 1.0], note='power icon: spark')
    # communications: waves going out
    fr = []
    for k in range(4):
        g = grid('comms')
        for y in range(16):
            for x in range(16):
                inner, outer = g[y][x] == 'U', g[y][x] == 'u'
                if (inner and k not in (1, 2)) or (outer and k not in (2, 3)): g[y][x] = '.'
        fr.append(to_img(g))
    add('ui', 'res_comms', 'idle', fr, fps=5, note='communications icon: pulsing waves')
    # time: grain of sand falling through the neck
    fr = []
    for k in range(4):
        g = grid('time')
        for y in range(5, 10):
            if g[y][8] == 'S': g[y][8] = 'u'
        g[6 + k][8] = 'S'
        fr.append(to_img(g))
    add('ui', 'res_time', 'idle', fr, fps=6, note='time icon: falling sand')
    # data: reading light going down the cylinder
    fr = []
    for r in (6, 7, 10, 11):
        g = grid('data'); g[r] = [('W' if ch == 'u' else ch) for ch in g[r]]; fr.append(to_img(g))
    add('ui', 'res_data', 'idle', fr, fps=6, note='data icon: reading')
    add('ui', 'res_budget', 'idle', shine('budget', [None, 6, 10, 14, 18, 22]), fps=10,
        durations=[14.0, 1.0, 1.0, 1.0, 1.0, 1.0], note='budget icon: coin shine')
    add('ui', 'res_mass', 'idle', shine('mass', [None, 8, 12, 16, 20, 24]), fps=10,
        durations=[14.0, 1.0, 1.0, 1.0, 1.0, 1.0], note='mass icon: shine')

def alert_icon(bright):
    c = C(16, 16)
    for i in range(11):
        c.R(7 - i // 2, 3 + i, 8 + i // 2, 3 + i, 'L' if bright else 'Y')
    c.R(7, 5, 8, 10, 'K'); c.R(7, 12, 8, 12, 'K')
    if bright: c.P(7, 4, 'W'); c.P(8, 4, 'W')
    return c.outline().img()

def register():
    res_icons()
    add('ui', 'ui_alert_icon', 'blink', [alert_icon(False), alert_icon(True)], fps=4, note='warning icon (triangle) blinking')
    add('ui', 'ui_bar_fill_red', 'blink', [bar_fill('X', 'N').img(), bar_fill('N', 'L').img()], fps=4,
        note='critical bar blinking; use as texture_progress by swapping the frame (same 9-slice margins: 2)')
    add('ui', 'ui_card_alert', 'blink', [card(True).img(), card(False).img()], fps=3,
        note='alert card header blinks red/rust; NinePatchRect margins L6 T12 R6 B6')
