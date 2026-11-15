# MARGIN — Art credits

> Paths below are relative to `game/art/`. Source scripts written as `_src/...` are in `art-source/` at the repository root; `margin/` means the `game/` folder.

## AI-assisted art (declared)
| Asset | Files | How it was made |
|---|---|---|
| Resource icons (mass, power, budget, data, comms, time) | `ui/res_*.png`, `ui/res_icons_sheet.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5), pixel by pixel, from a design brief by Pedro. Source script: `_src/make_res_icons.py`. Reviewed by the team. |
| Cargo grid item icons (19 items, 16 px per grid cell) | `items/item_*.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5) from the item list in `data/game-data.json`. Source script: `_src/make_item_icons.py`. Reviewed by the team. The medical kit uses a white cross on green (first-aid style), not the Red Cross emblem. |
| UI frame (9-slice): console panel, buttons (normal/hover/pressed/disabled), resource bar (under + green/yellow/red fill), decision card (normal/alert) | `ui/ui_*.png`, `ui/ui_slices.json` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5). Source script: `_src/make_ui_frame.py`. Reviewed by the team. |
| Map tiles (plain, rock, sand, slope, lander, target), map rovers, fog, path, target marker, cursor | `map/*.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5). Source script: `_src/make_map_tiles.py`. The 10x8 map layout is hand-made and only *inspired* by a Jezero-style delta site (not real elevation data). Reviewed by the team. |
| Crew portraits (Vega, Okoye, Tanaka, Duarte; normal and worried) | `crew/crew_*.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5). Fictional adult characters, not based on real people. Mission patch on the suit is generic (no NASA logo). Source script: `_src/make_crew_portraits.py`. Reviewed by the team. |
| EVA astronaut sprites (4 crew x 2 walk frames) | `crew/eva_*.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5). Source script: `_src/make_eva_events.py`. Reviewed by the team. |
| Event illustrations (dust storm, solar particle event, equipment failure) | `events/event_*.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5). Artistic, simplified scenes (not to scale, not real imagery). Source script: `_src/make_eva_events.py`. Reviewed by the team. |
| Title screen background + MARGIN logo | `ui/title_bg.png`, `ui/logo_margin*.png` | Pixel art drawn in code by Claude (Anthropic AI, Claude Opus 5.5). Blue glow around the setting Sun reflects how Martian sunsets look (artistic, not to scale). Source script: `_src/make_title.py`. Reviewed by the team. |
| Animations (74 animations / 47 Godot SpriteFrames: EVA crew, rovers, map markers, portraits blink/talk, UI, resource icons, title, events, landing, items, adjacency icons, screen FX) + landing background | `anim/**`, `ui/landing_bg.png` | Pixel art animated in code by Claude (Anthropic AI, Claude Opus 5.5), frame by frame, from the team's static art. Source scripts: `_src/anim_core.py`, `_src/anims_*.py`, `_src/make_anims.py`, `_src/make_godot.py`. Validated in Godot 4.3. Animation method follows the open agent skill `pixel-art-sprites` (omer-metin/skills-for-antigravity, Apache-2.0) as a reference; the EVA astronaut keeps the team-approved original design (gold visor). Reviewed by the team. |
| MARGIN palette v1 (16 colors) | `palette/margin_palette.*` | Defined by Claude with the team (Mars ochres + functional colors). |

## Third-party assets
None yet. (Only CC0 packs allowed. List pack, license and link here.)

## Fonts
| Font | License | Source |
|---|---|---|
| Press Start 2P (CodeMan38) | SIL Open Font License 1.1 (`fonts/OFL.txt`) | Fontsource npm package `@fontsource/press-start-2p` 5.3.0 (Google Fonts) |

## Music and sound effects (sat 14/11)
- Everything in `margin/audio/` (3 music loops: theme, surface, report; 10 effects) was **generated in code by Claude (Anthropic AI)**, synthesized with square/triangle waves and noise. No samples or third-party music. Generator: `margin/tools/make_audio.py`.
- `margin/art/map/map_scout_robot.png` (scout robot, 4 frames) and `map_dust_devil.png` (dust devil, 4 frames): pixel art drawn in code by Claude (AI), MARGIN palette. `sfx_motor` and `sfx_step` were synthesized in code by Claude.
- Scout robot redrawn (10 frames) and new sounds `sfx_motor_robot`, `sfx_motor_rover`, `sfx_robot_chirp`: made in code by Claude (AI).
- `item_charger.png`, `item_beacon.png`, `map_beacon.png` and 12 event sounds (`sfx_ev_*`, `sfx_beacon`, `sfx_charge`): made in code by Claude (AI).
- `map_boulder.png`, `map_crack.png` (map obstacles): drawn in code by Claude (AI).
