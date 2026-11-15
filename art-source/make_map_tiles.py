"""MARGIN — 16x16 map tiles, rovers on the map and map states (pixel art made in code, with AI: Claude).
Tiles are seamless (they fit side by side). Names follow the map legend in data/game-data.json."""
from PIL import Image, ImageDraw, ImageFont
import json, math, os, sys
from make_res_icons import PAL, rgba
from make_item_icons import C

def base(col, specks):
    c = C(16, 16); c.R(0, 0, 15, 15, col)
    for x, y, k in specks: c.P(x, y, k)
    return c

SPECKS = [(2, 1, 'O'), (9, 2, 'O'), (13, 4, 'L'), (5, 5, 'O'), (1, 8, 'L'), (11, 8, 'O'), (7, 10, 'O'),
          (14, 11, 'O'), (3, 13, 'O'), (10, 14, 'L'), (6, 15, 'O'), (12, 0, 'O'), (8, 6, 'L')]

def rock_at(c, x0, y0, w, h):
    c.R(x0, y0, x0 + w - 1, y0 + h - 1, 'R')
    c.R(x0, y0, x0 + w - 2, y0, 'S'); c.P(x0, y0, 'L')
    c.R(x0 + 1, y0 + h, x0 + w, y0 + h, 'O')          # shadow on the ground
    c.R(x0 + w - 1, y0 + 1, x0 + w - 1, y0 + h - 1, 'D')

def plain():
    return base('S', SPECKS)

def rock():
    c = base('S', SPECKS[::3])
    rock_at(c, 2, 3, 6, 4); rock_at(c, 10, 9, 4, 3); rock_at(c, 4, 11, 2, 2); rock_at(c, 12, 2, 2, 2)
    return c

def sand():
    c = base('L', [])
    for row in (2, 7, 12):
        for x in range(16):
            y = row + round(1.2 * math.sin(2 * math.pi * x / 16))
            c.P(x, y % 16, 'S'); c.P(x, (y + 1) % 16, 'W') if x % 4 == 0 else None
    return c

def slope():
    c = base('O', [])
    for y in range(16):
        for x in range(16):
            m = (x - y) % 8
            if m == 0: c.P(x, y, 'R')
            elif m == 1: c.P(x, y, 'S')
    for x, y in ((3, 12), (12, 5)): c.P(x, y, 'D')
    return c

def lander():
    c = base('S', SPECKS)
    c.disc(8.5, 8.5, 5.5, 'O')                                  # shadow
    for (x0, y0), (x1, y1) in (((2, 2), (5, 5)), ((13, 2), (10, 5)), ((2, 13), (5, 10)), ((13, 13), (10, 10))):
        c.L(x0, y0, x1, y1, 'G'); c.R(x0 - 1 if x0 < 8 else x0, y0 - 1 if y0 < 8 else y0,
                                      x0 if x0 < 8 else x0 + 1, y0 if y0 < 8 else y0 + 1, 'g')
    c.disc(7.5, 7.5, 5, 'W'); c.ring(7.5, 7.5, 5, 'G'); c.ring(7.5, 7.5, 4, 'g')
    c.R(4, 4, 6, 5, 'W'); c.P(10, 10, 'g'); c.P(9, 11, 'g'); c.P(11, 9, 'g')
    c.R(7, 7, 8, 8, 'U'); c.P(7, 7, 'u')                      # hatch
    c.R(11, 6, 12, 6, 'X')                                    # landing light
    return c

def target():
    c = base('S', SPECKS[1::2])
    for y in range(16):
        for x in range(16):
            if ((x - 7.5) / 6.2) ** 2 + ((y - 9) / 4.2) ** 2 <= 1:
                c.P(x, y, 'L' if y % 2 == 0 else 'O')
    for x in range(16):                                        # edge/shadow of the outcrop
        for y in range(15, 0, -1):
            if c.g[y][x] in 'LO' and c.g[y - 1][x] in 'LO' and (y + 1 > 15 or c.g[y + 1][x] == 'S'):
                c.P(x, y, 'R'); break
    c.P(5, 6, 'W'); c.P(6, 5, 'u'); c.P(6, 7, 'u'); c.P(7, 6, 'u'); c.P(5, 4, 'u')  # "interesting" shine
    return c

def rover_open_map():  # top view, facing right
    c = C(16, 16)
    for x0, y0 in ((2, 2), (10, 2), (2, 12), (10, 12)): c.R(x0, y0, x0 + 3, y0 + 1, 'G')
    c.box(1, 4, 14, 11, 'g', 'W', 'G')
    c.R(4, 5, 6, 7, 'G'); c.R(4, 8, 6, 10, 'G'); c.P(4, 5, 'g'); c.P(4, 8, 'g')
    c.R(9, 6, 10, 9, 'G'); c.P(9, 7, 'V')
    c.disc(12.5, 7.5, 1.3, 'W')
    return c.outline()

def rover_pressurized_map():
    c = C(16, 16)
    for x0 in (2, 6, 10):
        c.R(x0, 1, x0 + 2, 2, 'G'); c.R(x0, 13, x0 + 2, 14, 'G')
    c.box(1, 3, 14, 12, 'W', 'W', 'g')
    c.R(1, 3, 14, 3, 'U'); c.R(1, 12, 14, 12, 'U')
    c.R(12, 4, 14, 11, 'U'); c.R(12, 5, 12, 7, 'u')
    c.R(5, 6, 8, 9, 'g'); c.R(6, 7, 7, 8, 'G')
    return c.outline()

def fog():
    im = Image.new('RGBA', (16, 16))
    k, d = rgba(PAL['K'][1]), rgba(PAL['D'][1])
    for y in range(16):
        for x in range(16):
            col = d if (x + y) % 2 == 0 and (x * 3 + y * 5) % 7 == 0 else k
            im.putpixel((x, y), col[:3] + (225,))
    return im

def path_dot():
    c = C(16, 16); c.R(7, 7, 8, 8, 'W'); return c.outline()

def path_arrow():  # points right (rotate in Godot)
    c = C(16, 16)
    for i in range(4):
        c.R(6 + i, 4 + i, 7 + i, 4 + i, 'W'); c.R(6 + i, 11 - i, 7 + i, 11 - i, 'W')
    return c.outline()

def marker_target(frame):
    c = C(16, 16); dy = 0 if frame == 0 else 1
    c.disc(7.5, 5.5 + dy, 4, 'u'); c.ring(7.5, 5.5 + dy, 4, 'U')
    c.R(6, 4 + dy, 9, 7 + dy, 'W'); c.R(7, 3 + dy, 8, 8 + dy, 'W')
    for i, y in enumerate(range(9 + dy, 13 + dy)):
        c.R(6 + i // 2, y, 9 - i // 2, y, 'u')
    c.P(7, 13 + dy, 'U'); c.P(8, 13 + dy, 'U')
    c.outline()
    if frame == 0: c.R(6, 15, 9, 15, 'O')                       # shadow on the ground
    else: c.R(7, 15, 8, 15, 'O')
    return c

def cursor(frame):
    c = C(16, 16); o = 0 if frame == 0 else 1
    for (x, y, dx, dy) in ((o, o, 1, 1), (15 - o, o, -1, 1), (o, 15 - o, 1, -1), (15 - o, 15 - o, -1, -1)):
        for i in range(4): c.P(x + dx * i, y, 'W'); c.P(x, y + dy * i, 'W')
    return c

TILES = {'tile_plain': plain, 'tile_rock': rock, 'tile_sand': sand, 'tile_slope': slope,
         'tile_lander': lander, 'tile_target': target}
LEGEND = {'P': 'tile_plain', 'R': 'tile_rock', 'S': 'tile_sand', 'H': 'tile_slope', 'L': 'tile_lander', 'T': 'tile_target'}

if __name__ == '__main__':
    os.makedirs('out/map', exist_ok=True)
    imgs = {}
    for k, fn in TILES.items(): imgs[k] = fn().img()
    imgs['map_rover_open'] = rover_open_map().img()
    imgs['map_rover_pressurized'] = rover_pressurized_map().img()
    imgs['map_fog'] = fog()
    imgs['map_path_dot'] = path_dot().img()
    imgs['map_path_arrow'] = path_arrow().img()
    for f in (0, 1):
        imgs[f'map_marker_target_{f}'] = marker_target(f).img()
        imgs[f'map_cursor_{f}'] = cursor(f).img()
    for k, im in imgs.items(): im.save(f'out/map/{k}.png')
    # 96x16 tile sheet in the legend order P R S H L T
    sheet = Image.new('RGBA', (96, 16))
    for i, k in enumerate(['tile_plain', 'tile_rock', 'tile_sand', 'tile_slope', 'tile_lander', 'tile_target']):
        sheet.paste(imgs[k], (16 * i, 0))
    sheet.save('out/map/tiles_sheet.png')

    # ---- test map: the 10x8 map from game-data.json ----
    data = json.load(open(sys.argv[1], encoding='utf-8'))['map']
    rows = data['rows_data']
    m = Image.new('RGBA', (160, 128))
    for y, row in enumerate(rows):
        for x, ch in enumerate(row): m.alpha_composite(imgs[LEGEND[ch]], (16 * x, 16 * y))
    for x, y in ((3, 3), (3, 2)): m.alpha_composite(imgs['map_path_dot'], (16 * x, 16 * y))
    m.alpha_composite(imgs['map_path_arrow'], (16 * 4 - 8, 16 * 2))
    m.alpha_composite(imgs['map_rover_pressurized'], (16 * 1, 16 * 3))
    m.alpha_composite(imgs['map_rover_open'], (16 * 4, 16 * 3))
    for t in data['targets']:
        m.alpha_composite(imgs['map_marker_target_0'], (16 * t['pos'][0], 16 * t['pos'][1] - 10))
    m.alpha_composite(imgs['map_cursor_0'], (16 * 8, 16 * 3))
    for y in range(8):
        for x in range(10):
            if x >= 7 and not (x == 8 and y in (2, 3, 4)) and not (x == 7 and y in (3, 4)):
                m.alpha_composite(imgs['map_fog'], (16 * x, 16 * y))
    m.save('out/map/_map_preview_1x.png')

    S, font = 4, ImageFont.load_default(size=13)
    board = Image.new('RGBA', (1320, 2000), rgba('#2a2430')); d = ImageDraw.Draw(board)
    d.text((20, 4), 'Tiles, rovers and states (6x) - each tile repeated 3x3 to check the seams', fill='white', font=font)
    x, y = 20, 26
    for k in TILES:
        rep = Image.new('RGBA', (48, 48))
        for i in range(3):
            for j in range(3): rep.paste(imgs[k], (16 * i, 16 * j))
        board.alpha_composite(rep.resize((48 * 3, 48 * 3), Image.NEAREST), (x, y))
        d.text((x, y + 148), k, fill='white', font=font); x += 164
    x, y = 20, 200
    for k in ['map_rover_open', 'map_rover_pressurized', 'map_fog', 'map_path_dot', 'map_path_arrow',
              'map_marker_target_0', 'map_marker_target_1', 'map_cursor_0', 'map_cursor_1']:
        bg = Image.new('RGBA', (16, 16)); bg.paste(imgs['tile_plain'])
        bg.alpha_composite(imgs[k])
        board.alpha_composite(bg.resize((96, 96), Image.NEAREST), (x, y))
        d.text((x, y + 100), k.replace('map_', ''), fill='white', font=font); x += 140
    y = 330
    d.text((20, y), '10x8 map from game-data.json (4x): path, rovers, markers, cursor and fog to the east', fill='white', font=font)
    board.alpha_composite(m.resize((640, 512), Image.NEAREST), (20, y + 22))
    board = board.crop((0, 0, 1320, y + 22 + 512 + 16))
    board.save('preview_map.png'); print('ok', board.size)
