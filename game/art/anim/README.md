# MARGIN — animations for Godot 4

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

## Full list (74 animations)
| Entity | Animation | Frame | Frames | FPS | Loop | Use |
|---|---|---|---|---|---|---|
| `eva_vega` | `idle` | 16×16 | 4 | 4 | yes | idle: sub-pixel breathing, visor shine, helmet light (~1 s per cycle) |
| `eva_vega` | `walk` | 16×16 | 4 | 8 | yes | side walk (contact/passing, arm opposite the leg) facing right; flip_h for left. Move at ~32 px/s so the foot does not "slide" |
| `eva_vega` | `work` | 16×16 | 6 | 8 | yes | collecting a sample: anticipation, strike, held impact, recovery |
| `eva_vega` | `wave` | 16×16 | 4 | 5 | yes | waving (report, title, landing) |
| `eva_okoye` | `idle` | 16×16 | 4 | 4 | yes | idle: sub-pixel breathing, visor shine, helmet light (~1 s per cycle) |
| `eva_okoye` | `walk` | 16×16 | 4 | 8 | yes | side walk (contact/passing, arm opposite the leg) facing right; flip_h for left. Move at ~32 px/s so the foot does not "slide" |
| `eva_okoye` | `work` | 16×16 | 6 | 8 | yes | collecting a sample: anticipation, strike, held impact, recovery |
| `eva_okoye` | `wave` | 16×16 | 4 | 5 | yes | waving (report, title, landing) |
| `eva_tanaka` | `idle` | 16×16 | 4 | 4 | yes | idle: sub-pixel breathing, visor shine, helmet light (~1 s per cycle) |
| `eva_tanaka` | `walk` | 16×16 | 4 | 8 | yes | side walk (contact/passing, arm opposite the leg) facing right; flip_h for left. Move at ~32 px/s so the foot does not "slide" |
| `eva_tanaka` | `work` | 16×16 | 6 | 8 | yes | collecting a sample: anticipation, strike, held impact, recovery |
| `eva_tanaka` | `wave` | 16×16 | 4 | 5 | yes | waving (report, title, landing) |
| `eva_duarte` | `idle` | 16×16 | 4 | 4 | yes | idle: sub-pixel breathing, visor shine, helmet light (~1 s per cycle) |
| `eva_duarte` | `walk` | 16×16 | 4 | 8 | yes | side walk (contact/passing, arm opposite the leg) facing right; flip_h for left. Move at ~32 px/s so the foot does not "slide" |
| `eva_duarte` | `work` | 16×16 | 6 | 8 | yes | collecting a sample: anticipation, strike, held impact, recovery |
| `eva_duarte` | `wave` | 16×16 | 4 | 5 | yes | waving (report, title, landing) |
| `map_rover_open` | `idle` | 16×16 | 2 | 2 | yes | idle; console light blinks |
| `map_rover_open` | `drive` | 16×16 | 4 | 10 | yes | driving; dust behind |
| `map_rover_pressurized` | `idle` | 16×16 | 2 | 2 | yes | idle; headlights blink |
| `map_rover_pressurized` | `drive` | 16×16 | 4 | 10 | yes | driving; dust behind |
| `map_marker_target` | `bob` | 16×16 | 4 | 6 | yes | science target floating (loop) |
| `map_cursor` | `pulse` | 16×16 | 4 | 6 | yes | selection cursor pulsing |
| `map_path_arrow` | `pulse` | 16×16 | 4 | 8 | yes | path tip, points right (rotate with rotation) |
| `map_path_dot` | `blink` | 16×16 | 3 | 6 | yes | path dots; offset the start frame per cell for a "marching" effect |
| `crew_vega` | `idle_normal` | 48×48 | 4 | 8 | yes | idle portrait, blinks every ~2.5 s |
| `crew_vega` | `talk_normal` | 48×48 | 6 | 10 | yes | talking (loop while the text appears; when done, go back to idle_normal) |
| `crew_vega` | `idle_worried` | 48×48 | 6 | 8 | yes | worried, blinks more often and twice |
| `crew_vega` | `talk_worried` | 48×48 | 6 | 10 | yes | talking, worried |
| `crew_okoye` | `idle_normal` | 48×48 | 4 | 8 | yes | idle portrait, blinks every ~2.5 s |
| `crew_okoye` | `talk_normal` | 48×48 | 6 | 10 | yes | talking (loop while the text appears; when done, go back to idle_normal) |
| `crew_okoye` | `idle_worried` | 48×48 | 6 | 8 | yes | worried, blinks more often and twice |
| `crew_okoye` | `talk_worried` | 48×48 | 6 | 10 | yes | talking, worried |
| `crew_tanaka` | `idle_normal` | 48×48 | 4 | 8 | yes | idle portrait, blinks every ~2.5 s |
| `crew_tanaka` | `talk_normal` | 48×48 | 6 | 10 | yes | talking (loop while the text appears; when done, go back to idle_normal) |
| `crew_tanaka` | `idle_worried` | 48×48 | 6 | 8 | yes | worried, blinks more often and twice |
| `crew_tanaka` | `talk_worried` | 48×48 | 6 | 10 | yes | talking, worried |
| `crew_duarte` | `idle_normal` | 48×48 | 4 | 8 | yes | idle portrait, blinks every ~2.5 s |
| `crew_duarte` | `talk_normal` | 48×48 | 6 | 10 | yes | talking (loop while the text appears; when done, go back to idle_normal) |
| `crew_duarte` | `idle_worried` | 48×48 | 6 | 8 | yes | worried, blinks more often and twice |
| `crew_duarte` | `talk_worried` | 48×48 | 6 | 10 | yes | talking, worried |
| `res_power` | `idle` | 16×16 | 4 | 8 | yes | power icon: spark |
| `res_comms` | `idle` | 16×16 | 4 | 5 | yes | communications icon: pulsing waves |
| `res_time` | `idle` | 16×16 | 4 | 6 | yes | time icon: falling sand |
| `res_data` | `idle` | 16×16 | 4 | 6 | yes | data icon: reading |
| `res_budget` | `idle` | 16×16 | 6 | 10 | yes | budget icon: coin shine |
| `res_mass` | `idle` | 16×16 | 6 | 10 | yes | mass icon: shine |
| `ui_alert_icon` | `blink` | 16×16 | 2 | 4 | yes | warning icon (triangle) blinking |
| `ui_bar_fill_red` | `blink` | 16×8 | 2 | 4 | yes | critical bar blinking; use as texture_progress by swapping the frame (same 9-slice margins: 2) |
| `ui_card_alert` | `blink` | 32×32 | 2 | 3 | yes | alert card header blinks red/rust; NinePatchRect margins L6 T12 R6 B6 |
| `title_bg` | `idle` | 320×180 | 8 | 4 | yes | animated title background (stars, sun glow, habitat lights), WITHOUT astronauts: put title_crew_group or eva_* walking on top (ground at y≈128-142) |
| `title_crew_group` | `walk` | 64×16 | 4 | 8 | yes | the 4 walking in a row to the right; move x with a Tween (e.g. from -64 to 330 in ~14 s, y=126) and repeat |
| `logo_margin` | `shine` | 111×33 | 14 | 14 | yes | shine sweeping across the logo every ~2.5 s |
| `event_dust_storm` | `loop` | 160×90 | 6 | 8 | yes | moving wall of dust and gusts; continuous loop |
| `event_solar_particle_event` | `loop` | 160×90 | 4 | 8 | yes | rain of particles and pulsing corona; continuous loop |
| `event_equipment_failure` | `loop` | 160×90 | 6 | 6 | yes | rising smoke, sparks and blinking warning; continuous loop |
| `lander` | `descent` | 32×40 | 4 | 12 | yes | descending with the engine on; move y with a Tween. Anchor: footpads at y=27 of the frame (32x40) |
| `lander` | `landed` | 32×40 | 2 | 2 | yes | landed, lights blinking |
| `touchdown_dust` | `burst` | 80×24 | 7 | 12 | **no** | dust cloud on touchdown (NOT a loop). Center on the ship's x, base on the ground; hide when finished |
| `tile_target` | `sparkle` | 16×16 | 4 | 6 | yes | target tile with shine; use as an AnimatedSprite2D on top of the TileMap or as an animated tile in the TileSet |
| `tile_lander` | `blink` | 16×16 | 2 | 2 | yes | landing light blinking |
| `map_fog` | `shimmer` | 16×16 | 4 | 3 | yes | fog moving slowly; when revealing, fade with modulate.a |
| `item_fsp` | `active` | 32×32 | 4 | 4 | yes | reactor on: pulsing heat glow |
| `item_eclss` | `active` | 32×16 | 4 | 8 | yes | life support: fan spinning, green light |
| `item_battery` | `charging` | 16×16 | 4 | 3 | yes | battery charging (bars filling up) |
| `item_uhf` | `active` | 16×16 | 3 | 4 | yes | radio transmitting |
| `item_met` | `active` | 16×16 | 4 | 8 | yes | anemometer spinning |
| `item_spectrometer` | `active` | 16×16 | 4 | 6 | yes | spectrum changing on the screen |
| `item_solar` | `shine` | 32×16 | 5 | 8 | yes | reflection sweeping across the panel |
| `adj_heat` | `pulse` | 16×16 | 4 | 6 | yes | adjacency rule: HEAT (orange), rising waves |
| `adj_contam` | `pulse` | 16×16 | 2 | 3 | yes | adjacency rule: CONTAMINATION (brown) |
| `adj_shield` | `pulse` | 16×16 | 2 | 3 | yes | adjacency rule: SHIELDING (blue) |
| `fx_dust_overlay` | `loop` | 320×180 | 8 | 10 | yes | semi-transparent dust over the whole screen (320x180) during a storm; continuous loop |
| `fx_alert_vignette` | `pulse` | 320×180 | 2 | 3 | yes | pulsing red border (critical alert); on top of everything |
| `fx_sparkle` | `burst` | 16×16 | 6 | 12 | **no** | success sparkle (sample collected, objective met); NOT a loop |
