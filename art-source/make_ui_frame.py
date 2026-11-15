"""MARGIN — 9-slice UI frame (pixel art made in code, with AI: Claude).
Pieces: console, button (normal/hover/pressed/disabled), resource bar (background + 3 fills),
decision card (normal/alert). Margins in ui_slices.json (Godot: NinePatchRect patch_margin_* or
StyleBoxTexture texture_margin_*; bar: TextureProgressBar with nine_patch_stretch)."""
from PIL import Image, ImageDraw, ImageFont
import json, os
from make_res_icons import PAL, rgba
from make_item_icons import C

def corners_cut(c, n=1):
    for x, y in ((0, 0), (c.w - 1, 0), (0, c.h - 1), (c.w - 1, c.h - 1)): c.P(x, y, '.')
    if n > 1:
        for x, y in ((1, 0), (0, 1), (c.w - 2, 0), (c.w - 1, 1), (0, c.h - 2), (1, c.h - 1), (c.w - 1, c.h - 2), (c.w - 2, c.h - 1)):
            c.P(x, y, '.')

def frame(c, x0, y0, x1, y1, col):
    c.R(x0, y0, x1, y0, col); c.R(x0, y1, x1, y1, col); c.R(x0, y0, x0, y1, col); c.R(x1, y0, x1, y1, col)

def console():  # 24x24, margins 8
    c = C(24, 24)
    c.R(0, 0, 23, 23, 'K')
    c.R(1, 1, 22, 22, 'G')
    c.R(1, 1, 22, 1, 'g'); c.R(1, 1, 1, 22, 'g')          # light bevel
    c.R(1, 22, 22, 22, 'K'); c.R(22, 1, 22, 22, 'K')      # dark bevel
    c.R(2, 21, 21, 21, 'G')
    frame(c, 4, 4, 19, 19, 'K'); frame(c, 3, 3, 20, 20, 'G')
    c.R(3, 3, 20, 3, 'K'); c.R(3, 3, 3, 20, 'K')          # "sunken" screen
    c.R(5, 5, 18, 18, 'K')
    for x, y in ((2, 2), (21, 2), (2, 21), (21, 21)): c.P(x, y, 'W')   # rebites
    for x, y in ((2, 3), (3, 2)): c.P(x, y, 'g')
    corners_cut(c, 2)
    return c

def button(state):  # 16x16, margins L4 T3 R4 B5
    f, hi, sh = {'normal': ('O', 'S', 'R'), 'hover': ('S', 'L', 'O'),
                 'pressed': ('R', 'O', 'D'), 'disabled': ('G', 'g', 'K')}[state]
    c = C(16, 16)
    c.R(0, 0, 15, 15, 'K')
    if state == 'pressed':                       # pressed in: without the 3D "base"
        c.R(1, 3, 14, 14, f); c.R(1, 3, 14, 3, sh); c.R(2, 4, 13, 4, hi)
    else:
        c.R(1, 1, 14, 14, sh)                     # 3D base (2 px)
        c.R(1, 1, 14, 12, f)
        c.R(2, 1, 13, 1, hi); c.R(1, 2, 1, 11, hi)
    corners_cut(c, 2)
    if state == 'pressed':
        for x in range(16): c.P(x, 0, '.'); c.P(x, 1, '.')
        c.R(2, 2, 13, 2, 'K'); c.P(1, 3, 'K'); c.P(14, 3, 'K')
    return c

def bar_under():  # 16x8, margins 2
    c = C(16, 8)
    c.R(0, 0, 15, 7, 'K'); c.R(1, 1, 14, 6, 'G'); c.R(1, 1, 14, 1, 'g'); c.R(1, 1, 1, 6, 'g')
    c.R(2, 2, 13, 5, 'K')
    corners_cut(c)
    return c

def bar_fill(col, hi):
    c = C(16, 8)
    c.R(2, 2, 13, 5, col); c.R(2, 2, 13, 2, hi)
    return c

def card(alert=False):  # 32x32, margins L6 T12 R6 B6
    head, headhi = ('X', 'N') if alert else ('R', 'O')
    c = C(32, 32)
    c.R(0, 0, 31, 31, 'K')
    c.R(1, 1, 30, 30, 'O')
    c.R(2, 2, 29, 10, head); c.R(2, 2, 29, 2, headhi)
    c.R(2, 11, 29, 11, 'K')
    c.R(2, 12, 29, 29, 'W'); c.R(2, 29, 29, 29, 'L'); c.R(29, 12, 29, 29, 'L')
    corners_cut(c, 2)
    for x, y in ((1, 1), (30, 1), (1, 30), (30, 30)): c.P(x, y, 'K')
    return c

PIECES = {
    'ui_panel_console': (console(), dict(left=8, top=8, right=8, bottom=8)),
    'ui_button_normal': (button('normal'), dict(left=4, top=3, right=4, bottom=5)),
    'ui_button_hover': (button('hover'), dict(left=4, top=3, right=4, bottom=5)),
    'ui_button_pressed': (button('pressed'), dict(left=4, top=3, right=4, bottom=5)),
    'ui_button_disabled': (button('disabled'), dict(left=4, top=3, right=4, bottom=5)),
    'ui_bar_under': (bar_under(), dict(left=2, top=2, right=2, bottom=2)),
    'ui_bar_fill_green': (bar_fill('V', 'V'), dict(left=2, top=2, right=2, bottom=2)),
    'ui_bar_fill_yellow': (bar_fill('Y', 'L'), dict(left=2, top=2, right=2, bottom=2)),
    'ui_bar_fill_red': (bar_fill('X', 'N'), dict(left=2, top=2, right=2, bottom=2)),
    'ui_card': (card(), dict(left=6, top=12, right=6, bottom=6)),
    'ui_card_alert': (card(True), dict(left=6, top=12, right=6, bottom=6)),
}

def nine(im, m, w, h):
    """Renders a 9-slice (as Godot does with stretch) at size w x h."""
    W, H = im.size; L, T, R, B = m['left'], m['top'], m['right'], m['bottom']
    out = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    xs = [(0, L, 0, L), (L, W - R, L, w - R), (W - R, W, w - R, w)]
    ys = [(0, T, 0, T), (T, H - B, T, h - B), (H - B, H, h - B, h)]
    for sx0, sx1, dx0, dx1 in xs:
        for sy0, sy1, dy0, dy1 in ys:
            if dx1 > dx0 and dy1 > dy0 and sx1 > sx0 and sy1 > sy0:
                out.alpha_composite(im.crop((sx0, sy0, sx1, sy1)).resize((dx1 - dx0, dy1 - dy0), Image.NEAREST), (dx0, dy0))
    return out

def ptext(img, xy, s, col, size=8):
    """Text without antialiasing (mock; the game uses a pixel font, e.g. Press Start 2P)."""
    f = ImageFont.load_default(size=size)
    m = Image.new('L', img.size, 0); d = ImageDraw.Draw(m); d.fontmode = '1'
    d.text(xy, s, fill=255, font=f)
    img.paste(Image.new('RGBA', img.size, rgba(PAL[col][1])), (0, 0), m)

if __name__ == '__main__':
    os.makedirs('out/ui', exist_ok=True)
    imgs = {}
    for k, (c, m) in PIECES.items():
        im = c.img(); im.save(f'out/ui/{k}.png'); imgs[k] = (im, m)
    json.dump({k: {'size': list(im.size), 'patch_margin': m} for k, (im, m) in imgs.items()},
              open('out/ui/ui_slices.json', 'w'), indent=2)

    # ---- 320x180 test screen ----
    scr = Image.new('RGBA', (320, 180), rgba('#7a3424'))
    scr.alpha_composite(nine(*imgs['ui_panel_console'], 320, 30), (0, 0))
    res = ['mass', 'power', 'budget', 'data', 'comms', 'time']
    fills = [(0.8, 'green'), (0.55, 'yellow'), (0.25, 'red'), (0.9, 'green'), (0.6, 'yellow'), (0.4, 'yellow')]
    for i, r in enumerate(res):
        x = 8 + i * 51
        scr.alpha_composite(Image.open(f'out/ui/res_{r}.png'), (x, 7))
        scr.alpha_composite(nine(*imgs['ui_bar_under'], 30, 8), (x + 17, 11))
        fv, col = fills[i]
        fill = nine(*imgs[f'ui_bar_fill_{col}'], 30, 8)
        cut = 2 + round(26 * fv)
        scr.alpha_composite(fill.crop((0, 0, cut, 8)), (x + 17, 11))
    # cargo grid panel
    scr.alpha_composite(nine(*imgs['ui_panel_console'], 128, 120), (4, 34))
    grid = Image.open('out/items/_grid_preview_1x.png')
    scr.alpha_composite(grid, (12, 54))
    ptext(scr, (12, 41), 'LANDER CARGO 7x5', 'W')
    # decision card + buttons
    scr.alpha_composite(nine(*imgs['ui_card_alert'], 176, 112), (138, 36))
    ptext(scr, (146, 39), 'DUST STORM - SOL 12', 'W')
    for i, line in enumerate(['Solar output drops 70%.', 'Crew is 6 km from the hab.', 'What do you do?']):
        ptext(scr, (146, 52 + i * 11), line, 'K')
    for i, (st, lab) in enumerate([('normal', 'RETURN'), ('hover', 'SHELTER'), ('disabled', 'PUSH ON')]):
        bx = 146 + i * 54
        scr.alpha_composite(nine(*imgs[f'ui_button_{st}'], 50, 18), (bx, 122))
        ptext(scr, (bx + 6, 125), lab, 'W' if st != 'disabled' else 'g')
    scr.alpha_composite(nine(*imgs['ui_card'], 176, 30), (138, 150))
    ptext(scr, (146, 152), 'NEXT WINDOW', 'W')
    ptext(scr, (146, 164), 'Ascent in 9 sols', 'K')
    scr.save('out/ui/_screen_mock_1x.png')

    # board: pieces 6x + screen 4x
    S = 6
    font = ImageFont.load_default(size=13)
    board = Image.new('RGBA', (320 * 4 + 40, 2200), rgba('#2a2430'))
    d = ImageDraw.Draw(board)
    x, y = 20, 24
    d.text((20, 4), '9-slice pieces (6x)', fill='white', font=font)
    for k, (im, m) in imgs.items():
        big = im.resize((im.width * S, im.height * S), Image.NEAREST)
        if x + big.width > board.width - 20: x = 20; y += 32 * S + 30
        board.alpha_composite(big, (x, y))
        # margin lines
        L, T, R, B = m['left'] * S, m['top'] * S, m['right'] * S, m['bottom'] * S
        for xx in (x + L, x + big.width - R): d.line([(xx, y), (xx, y + big.height)], fill=(0, 255, 255, 120))
        for yy in (y + T, y + big.height - B): d.line([(x, yy), (x + big.width, yy)], fill=(0, 255, 255, 120))
        d.text((x, y + big.height + 4), k.replace('ui_', ''), fill='white', font=font)
        x += big.width + 24
    y += 32 * S + 34
    d.text((20, y), '320x180 test screen (4x) - text is a mock; the game uses a pixel font', fill='white', font=font)
    board.alpha_composite(scr.resize((1280, 720), Image.NEAREST), (20, y + 20))
    board = board.crop((0, 0, board.width, y + 20 + 720 + 16))
    board.save('preview_ui.png'); print('ok', board.size)
