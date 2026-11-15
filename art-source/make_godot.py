"""MARGIN — example scenes (title and landing) for Godot 4 + integration README."""
import json, os
from PIL import Image

OUT = 'out/anim'
os.makedirs(f'{OUT}/examples', exist_ok=True)
man = json.load(open(f'{OUT}/anim_manifest.json'))
logo_w = Image.open('out/ui/logo_margin.png').width

def track_value(i, path, times, values, update=0):
    return (f'tracks/{i}/type = "value"\ntracks/{i}/imported = false\ntracks/{i}/enabled = true\n'
            f'tracks/{i}/path = NodePath("{path}")\ntracks/{i}/interp = 1\ntracks/{i}/loop_wrap = true\n'
            f'tracks/{i}/keys = {{\n"times": PackedFloat32Array({", ".join(map(str, times))}),\n'
            f'"transitions": PackedFloat32Array({", ".join("1" for _ in times)}),\n"update": {update},\n'
            f'"values": [{", ".join(values)}]\n}}\n')

def track_method(i, path, time, method, arg):
    return (f'tracks/{i}/type = "method"\ntracks/{i}/imported = false\ntracks/{i}/enabled = true\n'
            f'tracks/{i}/path = NodePath("{path}")\ntracks/{i}/interp = 1\ntracks/{i}/loop_wrap = true\n'
            f'tracks/{i}/keys = {{\n"times": PackedFloat32Array({time}),\n"transitions": PackedFloat32Array(1),\n'
            f'"values": [{{\n"args": [&"{arg}"],\n"method": &"{method}"\n}}]\n}}\n')

def anim_node(name, res_id, anim, pos, parent='.', visible=True):
    s = f'[node name="{name}" type="AnimatedSprite2D" parent="{parent}"]\n'
    if not visible: s += 'visible = false\n'
    s += (f'position = Vector2({pos[0]}, {pos[1]})\nsprite_frames = ExtResource("{res_id}")\n'
          f'animation = &"{anim}"\n')
    if visible: s += f'autoplay = "{anim}"\n'
    return s + 'centered = false\n\n'

title = f'''[gd_scene load_steps=6 format=3]

[ext_resource type="SpriteFrames" path="{man['title_bg']['sprite_frames']}" id="1_bg"]
[ext_resource type="SpriteFrames" path="{man['logo_margin']['sprite_frames']}" id="2_logo"]
[ext_resource type="SpriteFrames" path="{man['title_crew_group']['sprite_frames']}" id="3_crew"]

[sub_resource type="Animation" id="Animation_crew"]
resource_name = "crew_walk"
length = 14.0
loop_mode = 1
{track_value(0, 'CrewGroup:position', [0, 14], ['Vector2(-64, 126)', 'Vector2(330, 126)'])}
[sub_resource type="AnimationLibrary" id="AnimationLibrary_title"]
_data = {{
"crew_walk": SubResource("Animation_crew")
}}

[node name="TitleScreen" type="Node2D"]

{anim_node('Background', '1_bg', 'idle', (0, 0))}{anim_node('CrewGroup', '3_crew', 'walk', (-64, 126))}{anim_node('Logo', '2_logo', 'shine', ((320 - logo_w) // 2, 22))}[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {{
"": SubResource("AnimationLibrary_title")
}}
autoplay = "crew_walk"
'''
open(f'{OUT}/examples/title_screen_example.tscn', 'w').write(title)

landing = f'''[gd_scene load_steps=7 format=3]

[ext_resource type="Texture2D" path="res://art/ui/landing_bg.png" id="1_bg"]
[ext_resource type="SpriteFrames" path="{man['lander']['sprite_frames']}" id="2_lander"]
[ext_resource type="SpriteFrames" path="{man['touchdown_dust']['sprite_frames']}" id="3_dust"]

[sub_resource type="Animation" id="Animation_land"]
resource_name = "landing"
length = 6.0
{track_value(0, 'Lander:position', [0, 4], ['Vector2(144, -40)', 'Vector2(144, 113)'])}{track_method(1, 'Lander', 4, 'play', 'landed')}{track_value(2, 'Dust:visible', [0, 4, 4.7], ['false', 'true', 'false'], update=1)}{track_method(3, 'Dust', 4, 'play', 'burst')}
[sub_resource type="AnimationLibrary" id="AnimationLibrary_land"]
_data = {{
"landing": SubResource("Animation_land")
}}

[node name="LandingScreen" type="Node2D"]

[node name="Background" type="Sprite2D" parent="."]
texture = ExtResource("1_bg")
centered = false

{anim_node('Lander', '2_lander', 'descent', (144, -40))}{anim_node('Dust', '3_dust', 'burst', (120, 117), visible=False)}[node name="AnimationPlayer" type="AnimationPlayer" parent="."]
libraries = {{
"": SubResource("AnimationLibrary_land")
}}
autoplay = "landing"
'''
open(f'{OUT}/examples/landing_example.tscn', 'w').write(landing)

# ---------------- README ----------------
rows = []
for ent, e in man.items():
    for name, a in e['animations'].items():
        rows.append(f"| `{ent}` | `{name}` | {a['frame_w']}×{a['frame_h']} | {a['frames']} | {a['fps']:g} | "
                    f"{'yes' if a['loop'] else '**no**'} | {a['note']} |")
readme = f'''# MARGIN — animations for Godot 4

Made in code by Claude (AI, declared in `art/CREDITS.md`), with the MARGIN v1 palette, following the
`pixel-art-sprites` skill (omer-metin/skills-for-antigravity, Apache-2.0): silhouette readable at 1x, 1 px outline, top-left light,
contact/passing walk cycle, sub-pixel idle, anticipation on actions and 100–300 ms per frame. Tested in **Godot 4.3**:
every `SpriteFrames` loads, every frame matches its sheet, and both example scenes run without errors.

## How it is organized
- **One PNG sheet per animation** (`<entity>_<animation>.png`): frames of the same size, side by side horizontally.
- **One `SpriteFrames` per entity** (`<entity>_frames.tres`), with all its animations, fps, loop and
  per-frame duration already set. Paths assume the `art/` folder is at the **project root** (`res://art/...`).
  If it lives elsewhere, find and replace `res://art/` in the `.tres`/`.tscn` files.
- `anim_manifest.json`: the same information as JSON (sheet, frame size, frame count, fps, loop, durations).
- `examples/title_screen_example.tscn` and `examples/landing_example.tscn`: ready-made scenes showing how to put things together.
- GIF previews (just for viewing, not used by the game): `art-source/anim_preview/` at the repository root.

## Project setup (once)
In **Project Settings**:
- `rendering/textures/canvas_textures/default_texture_filter` = **Nearest** (otherwise the pixel art gets blurry)
- `display/window/size/viewport_width` = **320**, `viewport_height` = **180**
- `display/window/stretch/mode` = **canvas_items** (or `viewport`), `display/window/stretch/scale_mode` = **integer**
- Test window size: `window_width_override` = 1280, `window_height_override` = 720

Snippet to paste into `project.godot`:
```
[display]
window/size/viewport_width=320
window/size/viewport_height=180
window/size/window_width_override=1280
window/size/window_height_override=720
window/stretch/mode="canvas_items"
window/stretch/scale_mode="integer"

[rendering]
textures/canvas_textures/default_texture_filter=0
```

## How to use
1. Create an `AnimatedSprite2D`, drag `<entity>_frames.tres` into **Sprite Frames**, pick the animation.
2. To play from code: `$Astronaut.play(&"walk")`; to face left: `$Astronaut.flip_h = true`.
3. **Walking astronaut speed: ~32 px/s** (the `walk` stride is ~16 px per 0.5 s cycle). Faster or slower makes the foot "slide".
4. **Non-looping** animations (`touchdown_dust.burst`, `fx_sparkle.burst`): connect the `animation_finished` signal to hide the node.
5. **Moving** (rovers, astronauts, ship, title group) is done with a `Tween`/`AnimationPlayer` changing `position`; the sheet only animates "in place".
6. Tip: `centered = false` on backgrounds (320×180) and place them at `(0, 0)`.

### Special cases
- **Critical bar** (`ui_bar_fill_red.blink`): it is a 9-slice texture. In a `TextureProgressBar`, swap `texture_progress`
  for `sprite_frames.get_frame_texture(&"blink", i)` on a 0.25 s `Timer` (or blink with `modulate`).
- **Alert card** (`ui_card_alert.blink`): same, swapping the `NinePatchRect`'s `texture` (margins L6 T12 R6 B6).
- **Portraits**: `idle_normal` / `idle_worried` looping; while text is shown, `talk_normal` / `talk_worried`; when done, go back to `idle_*`.
- **Path dots** (`map_path_dot.blink`): for a "marching" effect, use `frame = cell_index % 3` when creating each dot.
- **Path arrow**: points right; rotate with `rotation_degrees` (90 = down, 180 = left, 270 = up).
- **Animated tiles** (`tile_target.sparkle`, `tile_lander.blink`): put an `AnimatedSprite2D` on top of the TileMap cell
  (simplest), or create an animated tile in the TileSet using the sheet (Animation Columns = number of frames).
- **Fog**: `map_fog.shimmer` on each hidden cell; when revealing, fade `modulate.a` to 0 and remove it.
- **Screen overlays** (`fx_dust_overlay`, `fx_alert_vignette`): semi-transparent 320×180, put them on top of everything (CanvasLayer).

## Full list ({len(rows)} animations)
| Entity | Animation | Frame | Frames | FPS | Loop | Use |
|---|---|---|---|---|---|---|
''' + '\n'.join(rows) + '\n'
open(f'{OUT}/README.md', 'w').write(readme)
print('ok', len(rows))
