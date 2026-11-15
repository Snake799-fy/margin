"""MARGIN — crew portraits 48x48, normal and worried expressions
(pixel art made in code, with AI: Claude). Fictional adult crew members."""
from PIL import Image, ImageDraw, ImageFont
import os
from make_res_icons import PAL, rgba
from make_item_icons import C

CREW = {
    #         skin, shadow, mouth, hair, hair_light, eyebrow, suit stripe, style
    'vega':   dict(skin='L', sh='S', mouth='R', hair='g', hl='W', brow='G', stripe='X', style='vega'),
    'okoye':  dict(skin='B', sh='D', mouth='D', hair='D', hl='R', brow='D', stripe='Y', style='okoye'),
    'tanaka': dict(skin='L', sh='S', mouth='R', hair='D', hl='G', brow='D', stripe='N', style='tanaka'),
    'duarte': dict(skin='S', sh='O', mouth='R', hair='R', hl='O', brow='R', stripe='V', style='duarte'),
}

def in_head(x, y):
    cy, top = 20.5, 9
    if y < top or y > 31: return False
    rx = 9.6 if y <= 22 else 9.6 - (y - 22) * 0.5
    ry = 11.5
    return ((x - 23.5) / rx) ** 2 + ((y - cy) / ry) ** 2 <= 1.0 if y <= 22 else abs(x - 23.5) <= rx

def dome(x, y):
    return y <= 22 and ((x - 23.5) / 10.8) ** 2 + ((y - 20) / 12.6) ** 2 <= 1.0

def portrait(cid, worried, eyes='open', mouth=None):
    p = CREW[cid]; c = C(48, 48)
    # hair behind the head
    if p['style'] == 'okoye':
        c.disc(23.5, 14, 13.5, p['hair'])
        for x, y in ((14, 6), (18, 3), (27, 3), (32, 7), (12, 11), (35, 12), (22, 2), (30, 4), (16, 8)):
            c.P(x, y, p['hl'])
    if p['style'] == 'duarte':
        c.disc(23.5, 6, 4, p['hair']); c.P(22, 4, p['hl']); c.P(23, 3, p['hl'])
        for y in range(48):
            for x in range(48):
                if y <= 26 and ((x - 23.5) / 11.4) ** 2 + ((y - 18) / 11) ** 2 <= 1: c.P(x, y, p['hair'])
    # suit (shoulders) + collar
    for y in range(35, 48):
        half = min(21, 9 + (y - 35) * 4)
        c.R(round(23.5 - half), y, round(23.5 + half), y, 'W')
        c.R(round(23.5 + half) - 5, y, round(23.5 + half), y, 'g')
    c.R(3, 42, 44, 43, p['stripe'])
    c.R(16, 38, 16, 47, 'g'); c.R(31, 38, 31, 47, 'g')       # seams
    c.R(19, 39, 21, 40, 'U'); c.P(19, 39, 'W')                  # mission patch (generic)
    # neck
    c.R(19, 29, 28, 35, p['skin']); c.R(19, 30, 28, 31, p['sh']); c.R(26, 32, 28, 35, p['sh'])
    c.R(16, 34, 31, 36, 'g'); c.R(16, 36, 31, 36, 'G'); c.R(17, 34, 30, 34, 'W')   # helmet ring
    # ears
    for x0 in (13, 33):
        c.R(x0, 19, x0 + 1, 23, p['skin']); c.P(x0 + (1 if x0 == 13 else 0), 21, p['sh'])
    # head
    for y in range(48):
        for x in range(48):
            if in_head(x, y): c.P(x, y, p['sh'] if x >= 30 or y >= 30 else p['skin'])
    # front hair / styles
    st = p['style']
    for y in range(48):
        for x in range(48):
            if not dome(x, y): continue
            if st == 'vega' and (y <= 12 or (y <= 17 and (x <= 15 or x >= 32))):
                c.P(x, y, p['hair'] if (x + y) % 5 else p['hl'])
            if st == 'okoye' and (y <= 12 or (y <= 16 and (x <= 15 or x >= 32))):
                c.P(x, y, p['hair'])
            if st == 'tanaka' and (y <= 12 or (y <= 15 and x <= 23 - (y - 12) * 2) or (y <= 18 and (x <= 15 or x >= 32))):
                c.P(x, y, p['hair'])
            if st == 'duarte' and (y <= 12 or (y <= 14 and (x <= 17 or x >= 30))):
                c.P(x, y, p['hair'])
    if st == 'vega':
        c.R(19, 8, 22, 8, 'W'); c.P(17, 9, 'W')
        for y in range(26, 32):                                  # short beard
            for x in range(48):
                if in_head(x, y) and (y >= 30 or x <= 18 or x >= 29 or y == 29 and 20 <= x <= 27):
                    c.P(x, y, 'g' if (x * 7 + y * 3) % 4 else 'G')
    if st == 'tanaka':
        c.P(18, 9, p['hl']); c.P(19, 9, p['hl']); c.P(20, 10, p['hl'])
    if st == 'duarte':
        c.R(19, 9, 24, 9, p['hl'])
        c.P(13, 25, 'Y')                                         # earring
    if st == 'okoye':
        for x, y in ((18, 10), (25, 9), (29, 11)): c.P(x, y, p['hl'])
    # eyebrows
    b = p['brow']
    if worried:
        for x, y in ((17, 18), (18, 18), (19, 17), (20, 16), (21, 16)): c.P(x, y, b)
        for x, y in ((26, 16), (27, 16), (28, 17), (29, 18), (30, 18)): c.P(x, y, b)
    else:
        for x, y in ((17, 18), (18, 17), (19, 17), (20, 17), (21, 17)): c.P(x, y, b)
        for x, y in ((26, 17), (27, 17), (28, 17), (29, 17), (30, 18)): c.P(x, y, b)
    # eyes
    iris = 'D' if p['skin'] != 'B' else 'K'
    c.P(18, 20, 'W'); c.P(18, 21, 'W'); c.R(19, 20, 20, 21, iris); c.P(19, 20, 'W' if not worried else iris)
    c.P(29, 20, 'W'); c.P(29, 21, 'W'); c.R(27, 20, 28, 21, iris); c.P(27, 20, 'W' if not worried else iris)
    if worried: c.P(18, 22, p['sh']); c.P(29, 22, p['sh'])      # light under-eye shadow
    if eyes == 'half':
        c.R(18, 20, 20, 20, p['sh']); c.R(27, 20, 29, 20, p['sh'])
    elif eyes == 'closed':
        c.R(18, 20, 20, 21, p['skin']); c.R(27, 20, 29, 21, p['skin'])
        c.R(18, 21, 20, 21, p['brow']); c.R(27, 21, 29, 21, p['brow'])
    if st == 'tanaka':                                           # glasses
        for x0 in (16, 25):
            c.R(x0, 19, x0 + 5, 19, 'G'); c.R(x0, 22, x0 + 5, 22, 'G')
            c.R(x0, 19, x0, 22, 'G'); c.R(x0 + 5, 19, x0 + 5, 22, 'G')
        c.R(22, 20, 24, 20, 'G')
    # nose
    for x, y in ((25, 22), (25, 23), (25, 24), (23, 25), (24, 25)): c.P(x, y, p['sh'])
    # mouth
    m = p['mouth']
    if worried: c.P(33, 12, 'u'); c.R(33, 13, 34, 14, 'u'); c.P(33, 13, 'W')   # drop of sweat
    if mouth is not None:
        if worried:
            c.P(21, 29, m); c.P(22, 28, m); c.R(23, 28, 25, 28, m); c.P(26, 28, m); c.P(27, 29, m)
            if mouth >= 1: c.R(23, 29, 25, 29, 'D')
            if mouth >= 2: c.R(22, 29, 26, 30, 'D'); c.R(23, 31, 25, 31, m)
        else:
            c.P(21, 27, m); c.R(22, 28, 26, 28, m); c.P(27, 27, m)
            if mouth >= 1: c.R(23, 29, 25, 29, 'D')
            if mouth >= 2: c.R(22, 29, 26, 30, 'D'); c.R(23, 31, 25, 31, m)
        return c.outline()
    if worried:
        c.P(21, 29, m); c.P(22, 28, m); c.R(23, 28, 25, 28, m); c.P(26, 28, m); c.P(27, 29, m)
        c.R(23, 29, 25, 29, 'D')
    else:
        c.P(21, 27, m); c.R(22, 28, 26, 28, m); c.P(27, 27, m)
    return c.outline()

if __name__ == '__main__':
    os.makedirs('out/crew', exist_ok=True)
    imgs = {}
    for cid in CREW:
        for ex in ('normal', 'worried'):
            im = portrait(cid, ex == 'worried').img()
            im.save(f'out/crew/crew_{cid}_{ex}.png'); imgs[(cid, ex)] = im
    sheet = Image.new('RGBA', (48 * 2, 48 * 4))
    for j, cid in enumerate(CREW):
        for i, ex in enumerate(('normal', 'worried')): sheet.paste(imgs[(cid, ex)], (48 * i, 48 * j))
    sheet.save('out/crew/crew_sheet.png')

    S, font = 4, ImageFont.load_default(size=13)
    names = {'vega': 'Cmdr. Vega - Commander', 'okoye': 'Dr. Okoye - Geologist',
             'tanaka': 'Eng. Tanaka - Engineer', 'duarte': 'Dr. Duarte - Physician'}
    board = Image.new('RGBA', (1240, 560), rgba('#2a2430')); d = ImageDraw.Draw(board)
    d.text((20, 4), 'Portraits 48x48 (4x): normal / worried - on the console panel', fill='white', font=font)
    for j, cid in enumerate(CREW):
        x = 20 + j * 304
        for i, ex in enumerate(('normal', 'worried')):
            bg = Image.new('RGBA', (48, 48), rgba(PAL['K'][1]))
            bg.alpha_composite(imgs[(cid, ex)])
            board.alpha_composite(bg.resize((48 * 3, 48 * 3), Image.NEAREST), (x + i * 148, 26))
        d.text((x, 26 + 148), names[cid], fill='white', font=font)
    d.text((20, 210), 'Actual size 1x and 2x:', fill='white', font=font)
    board.alpha_composite(sheet.transpose(Image.Transpose.TRANSPOSE).transpose(Image.Transpose.FLIP_LEFT_RIGHT).rotate(0), (20, 232)) if False else None
    row = Image.new('RGBA', (48 * 8, 48))
    for j, cid in enumerate(CREW):
        for i, ex in enumerate(('normal', 'worried')): row.paste(imgs[(cid, ex)], (48 * (j * 2 + i), 0))
    bgrow = Image.new('RGBA', row.size, rgba(PAL['K'][1])); bgrow.alpha_composite(row)
    board.alpha_composite(bgrow, (20, 232)); board.alpha_composite(bgrow.resize((768, 96), Image.NEAREST), (20, 296))
    board = board.crop((0, 0, 1240, 410))
    board.save('preview_crew.png'); print('ok')
