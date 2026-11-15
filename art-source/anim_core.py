"""MARGIN — animation export core for Godot 4.
Each animation becomes a horizontal PNG sheet (frames of the same size, side by side).
Each entity becomes a SpriteFrames .tres with all its animations."""
from PIL import Image
import json, os

RES_ROOT = 'res://art/anim'
OUT = 'out/anim'
REG = []

def add(group, entity, name, frames, fps, loop=True, durations=None, note=''):
    w, h = frames[0].size
    for f in frames: assert f.size == (w, h), (entity, name, f.size)
    durations = durations or [1.0] * len(frames)
    assert len(durations) == len(frames)
    REG.append(dict(group=group, entity=entity, name=name, frames=frames, fps=fps, loop=loop,
                    durations=durations, w=w, h=h, note=note))

def _tres(entity, anims):
    lines, sub = [], []
    ext = []
    for i, a in enumerate(anims):
        ext.append(f'[ext_resource type="Texture2D" path="{RES_ROOT}/{a["group"]}/{entity}_{a["name"]}.png" id="{i + 1}_{a["name"]}"]')
    for i, a in enumerate(anims):
        for j in range(len(a['frames'])):
            sub.append(f'[sub_resource type="AtlasTexture" id="AtlasTexture_{a["name"]}_{j}"]\n'
                       f'atlas = ExtResource("{i + 1}_{a["name"]}")\n'
                       f'region = Rect2({j * a["w"]}, 0, {a["w"]}, {a["h"]})\n')
    anim_objs = []
    for a in anims:
        fr = ', '.join('{\n"duration": %s,\n"texture": SubResource("AtlasTexture_%s_%d")\n}' % (repr(float(d)), a['name'], j)
                       for j, d in enumerate(a['durations']))
        anim_objs.append('{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %s\n}' %
                         (fr, 'true' if a['loop'] else 'false', a['name'], repr(float(a['fps']))))
    n = len(ext) + len(sub) + 1
    out = f'[gd_resource type="SpriteFrames" load_steps={n} format=3]\n\n' + '\n'.join(ext) + '\n\n'
    out += '\n'.join(sub) + '\n[resource]\nanimations = [' + ', '.join(anim_objs) + ']\n'
    return out

def export(preview_dir='out/anim_preview', bg=(42, 36, 48, 255)):
    os.makedirs(OUT, exist_ok=True); os.makedirs(preview_dir, exist_ok=True)
    manifest = {}
    by_entity = {}
    for a in REG:
        d = f'{OUT}/{a["group"]}'; os.makedirs(d, exist_ok=True)
        strip = Image.new('RGBA', (a['w'] * len(a['frames']), a['h']), (0, 0, 0, 0))
        for j, f in enumerate(a['frames']): strip.paste(f, (j * a['w'], 0))
        strip.save(f'{d}/{a["entity"]}_{a["name"]}.png')
        by_entity.setdefault((a['group'], a['entity']), []).append(a)
        # GIF preview (integer scale, dark background)
        s = 6 if a['w'] <= 16 else 4 if a['w'] <= 48 else 3 if a['w'] <= 160 else 2
        gif = []
        for f in a['frames']:
            b = Image.new('RGBA', f.size, bg); b.alpha_composite(f)
            gif.append(b.resize((f.width * s, f.height * s), Image.NEAREST).convert('RGB'))
        ms = [max(20, round(1000 * d / a['fps'] / 10) * 10) for d in a['durations']]
        # single exact palette for all frames (no color swapping)
        cols = []
        for g in gif:
            for cnt, c in g.getcolors(1 << 20):
                if c not in cols: cols.append(c)
        assert len(cols) <= 256, (a['entity'], len(cols))
        pal = Image.new('P', (1, 1)); flat = [v for c in cols for v in c]; pal.putpalette(flat + [0] * (768 - len(flat)))
        gif = [g.quantize(palette=pal, dither=Image.Dither.NONE) for g in gif]
        gif[0].save(f'{preview_dir}/{a["entity"]}_{a["name"]}.gif', save_all=True, append_images=gif[1:],
                    duration=ms, loop=0, disposal=1, optimize=False)
    for (g, ent), anims in by_entity.items():
        open(f'{OUT}/{g}/{ent}_frames.tres', 'w').write(_tres(ent, anims))
        manifest[ent] = dict(sprite_frames=f'{RES_ROOT}/{g}/{ent}_frames.tres', animations={
            a['name']: dict(sheet=f'{RES_ROOT}/{g}/{ent}_{a["name"]}.png', frame_w=a['w'], frame_h=a['h'],
                            frames=len(a['frames']), fps=a['fps'], loop=a['loop'], durations=a['durations'],
                            note=a['note']) for a in anims})
    json.dump(manifest, open(f'{OUT}/anim_manifest.json', 'w'), indent=1, ensure_ascii=False)
    return manifest
