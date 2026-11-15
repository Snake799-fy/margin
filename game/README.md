# MARGIN — Godot 4 project

Game for the NASA Space Apps Challenge 2026 (Belo Horizonte), challenge 13 (*Space Mission Design Game*).
All the art, animations, UI theme, map TileSet, font, audio, data and gameplay scripts are here and configured.
Tested in **Godot 4.3** and **Godot 4.7**.

## Open
1. Godot 4.3 or newer → **Import** → select this `project.godot`.
2. Wait for the import. Press **F5**: the animated title screen opens (main scene), then the game.
3. Open `scenes/ui_kit_demo.tscn` and press **F6** to see the UI kit (buttons, bars, card, portrait, astronaut).

## What is already configured
- Resolution **320×180**, 1280×720 window, `canvas_items` stretch with **integer scale**, **Nearest** filter (crisp pixel art), pixel snap.
- **Compatibility** renderer (the right one for Web export).
- **Global theme** `resources/margin_theme.tres` (applied to the whole project):
  - **Press Start 2P** font at 8 px without antialiasing (`fonts/press_start_2p.tres`).
  - `Button`: 4 states with the 9-slice textures; dark text on hover (contrast).
  - `Panel` / `PanelContainer`: "console" panel.
  - Variations: `CardPanel` (normal card), `CardPanelAlert` (alert card) and `CardText` (dark text for the card body).
    Use them in `theme_type_variation`. The **first** Label inside the card sits in the title strip; the rest goes in the body.
- **TileSet** `resources/margin_tileset.tres` (16×16), source 0, atlas coordinates in the order of the JSON legend:
  `P=(0,0) plain · R=(1,0) rock · S=(2,0) sand · H=(3,0) slope · L=(4,0) lander · T=(5,0) target`.
- **Web export** ready in `export_presets.cfg` (no threads, good for GitHub Pages; output in `../docs/`, served by GitHub Pages).
  You only need to install Godot's *export templates* (Editor → Manage Export Templates).

## Folders
| Folder | Contents |
|---|---|
| `art/` | all the art. **Read `art/anim/README.md`**: how to use each animation, special cases and the full list (74 animations) |
| `art/anim/` | animations: one PNG sheet per animation + one `SpriteFrames` (`.tres`) per character/object |
| `art/anim/examples/` | example scenes (title and landing) |
| `audio/` | chiptune music and sound effects (generated in code, see `tools/make_audio.py`) |
| `data/game-data.json` | game data (components, events, crew, scoring) |
| `fonts/` | Press Start 2P + OFL license |
| `resources/` | UI theme and TileSet |
| `scenes/` | `title.tscn` (main scene), `main.tscn` (game) and `ui_kit_demo.tscn` |
| `scripts/` | gameplay code: `gs.gd` (autoload **GS**, all the rules), one `screen_*.gd` per phase, `cargo_grid.gd`, `hud.gd`, `ui.gd`, `audio.gd` |
| `tools/` | scripts that generate the theme/TileSet/audio and validate the animations (not part of the game) |
| root `.gd`/`.tscn` files | The programmer's first cargo-grid prototype (`maleta` = case/suitcase, `grade` = grid, `largura`/`altura` = width/height) |

## Reading the data
```gdscript
var data = JSON.parse_string(FileAccess.get_file_as_string("res://data/game-data.json"))
for c in data["components"]:
    var icon = load("res://art/items/item_%s.png" % c["id"])   # item icon = JSON id
```
Names follow the JSON ids: `art/items/item_<id>.png`, `art/crew/crew_<id>_normal.png`, `art/anim/crew/eva_<id>_frames.tres`, `art/events/event_<id>.png`.

## Quick tips
- Walking astronaut: move at **~32 px/s** (otherwise the foot "slides"). `flip_h = true` for left.
- Non-looping animations (`touchdown_dust.burst`, `fx_sparkle.burst`): hide them on the `animation_finished` signal.
- Game texts are in **English**. All art and audio were made with AI (Claude) and are declared in `art/CREDITS.md`.
