---
tags: [nasa-space-apps, art, pedro]
---
# Art list (Pedro) — pixel art

> Paths: in the repository the game art lives in `game/art/` and the generator scripts and previews (written below as `art/_src/`) live in `art-source/`.

## Style rules
- Base resolution **320×180**, scaled up by an integer factor (6×, 4×…). No "half-pixel" lines.
- **Tile = 16×16.** Item icons = 16×16 per grid cell (2×2 item = 32×32).
- Palette of **~16 colors**: Mars ochres/rust (background) + **functional colors**: green (ok), yellow (caution), red (danger), orange (heat), brown (contamination), blue (shielding). Color **always with an icon** (accessibility).
- Export PNG with a transparent background, **sprite sheets on a fixed grid**, and put everything in an `art/` folder in the repository with simple names (`item_fsp.png`).
- **No NASA logos or symbols.** Third-party packs: CC0 only (e.g. Kenney) and **write down the source**. AI-made art: tell the team (it needs a watermark and a declaration).
- Suggested text font: *Press Start 2P* (OFL license; confirm on download) or another free pixel font.

## P0 — without this the game doesn't run (≈ 45 pieces, ~8–10 h)
| Group | Pieces | Size |
|---|---|---|
| Interface | "console" frame, button (normal/hover/disabled), resource bar (green/yellow/red), decision card (background + border) | 9-slice 16 px |
| Resource icons (6) | mass, power, budget, data, communications, time | 16×16 |
| **Grid items (≈ 18)** | fission `2×2`, solar panel `2×1`, battery, life support `2×1`, water tank, supply crate, shelter `2×1`, pressurized rover `2×2`, open rover `2×1`, extra suits, drill/field kit, sample container, spectrometer, radar `1×2`, met, medical kit, high-gain antenna `1×2`, UHF radio, spares | 16×16 per cell |
| **Crew portraits (4 × 2 expressions)** | Vega, Okoye, Tanaka, Duarte: normal and worried | 48×48 |
| Field sprites (4) | suited astronauts (each with a different stripe color), 2 walking frames | 16×16 |
| Map tiles (6) | plain, rock, sand, slope, science target, lander/habitat | 16×16 |
| Vehicles on the map | open rover, pressurized rover | 16×16 |
| Map states | fog, arrow/path, target marker | 16×16 |
| Event illustrations (5) | dust, solar storm, failure, medical, relay | 160×90 |
| Key screens (3) | title, report (background), landing | 320×180 |

## P1 — brings it to life (if there is time, ~3 h)
- Martian sun and sky with variation (day/dust) as the surface background.
- **Adjacency line** icons (heat, contamination, shielding) animated with 2 frames.
- Dust effect (semi-transparent overlay) and alert blink.
- Landing: 4 simple frames (ship descending).
- Game logo "MARGIN" (or final title).

## P2 — extras
- Launch animation, full EDL, 3rd site, CubeSat scenario, achievement icons.

## Suggested order (so the programmer can integrate early)
1. **Today by 5 pm:** item icons + 6 resource icons + UI frame + map tiles (**even as drafts**). The programmer uses colored squares until the art arrives and swaps them later.
2. **By 10 pm:** portraits + field sprites + event illustrations.
3. **Sunday 9–11 am:** landing, title, report, contrast tweaks. After that, only polish.

## Status (updated Sat 11/14, ~6 pm)
P0 art being made **in code by Claude** (pixel by pixel, AI declared in `art/CREDITS.md`); Pedro approves and adjusts. Until there is a repository, the files stay in `art/` in this vault; the programmer copies them to the repo.
- [x] **MARGIN palette v1 (16 colors)** → `art/palette/` (`.hex` for Aseprite/Lospec, `.gpl` for GIMP, `.png`). Order: outline `#1a1020` · Mars `#3b1f1a #7a3424 #b5552e #d98c4a #f0c48a` · grays `#5a5a6e #a0a0b0` · white `#f4f0e8` · functional: ok green `#4fb04a`, caution yellow `#f2c230`, danger red `#d6362f`, heat orange `#f07a1e`, contamination brown `#7a5230`, shielding blue `#3a7bd5`, light blue `#8fc7f0`.
- [x] **6 resource icons (draft v1)** → `art/ui/res_mass.png`, `res_power.png`, `res_budget.png`, `res_data.png`, `res_comms.png`, `res_time.png` + sheet `res_icons_sheet.png` (96×16, in that order). Concepts: weight (mass), lightning bolt (power), $ coin (budget), data cylinder (data), mast with waves (communications), hourglass with Martian sand (time). Review board: `art/_src/preview_res_icons.png`; script: `art/_src/make_res_icons.py`.
- [x] **Grid item icons (19, draft v1)** → `art/items/item_<id>.png`, with the same `id` as `data/game-data.json` and size = 16 px × cells (e.g. `item_fsp.png` 32×32, `item_gpr.png` 16×32). All checked together on the lander's 7×5 grid (`art/_src/preview_items.png`); script `art/_src/make_item_icons.py`. Color reading: heat = orange glow on the reactor; contaminant (field kit) = brown; water/shelter/pressurized rover = blue (shielding); samples = green caps (clean). Medical kit with a **white cross on green** (first-aid standard), not the Red Cross emblem, which is protected.
- [x] **9-slice UI frame (draft v1)** → `art/ui/ui_*.png` + margins in `art/ui/ui_slices.json` (Godot: `NinePatchRect.patch_margin_*` or `StyleBoxTexture.texture_margin_*`; bar = `TextureProgressBar` with `nine_patch_stretch`, `under` = `ui_bar_under`, `progress` = one of the `ui_bar_fill_*`).
  - `ui_panel_console` 24×24, margins 8 (riveted metal, dark screen).
  - `ui_button_normal/hover/pressed/disabled` 16×16, margins L4 T3 R4 B5 (ochre → light ochre → pressed in → gray). **Button text:** white `#f4f0e8` on normal/pressed; **dark `#1a1020` on hover** (white on light ochre has little contrast); gray `#a0a0b0` on disabled.
  - `ui_bar_under` + `ui_bar_fill_green/yellow/red` 16×8, margins 2. Color always next to the resource icon.
  - `ui_card` / `ui_card_alert` 32×32, margins L6 T12 R6 B6 (rust / red title strip, light body with dark text).
  - 320×180 test screen built with all the pieces: `art/_src/screen_mock_1x.png` (board `art/_src/preview_ui.png`; script `art/_src/make_ui_frame.py`).
- [x] **Map tiles (6) + rovers on the map + map states (draft v1)** → `art/map/`.
  - Seamless 16×16 tiles, named after the JSON legend: `tile_plain` (P), `tile_rock` (R), `tile_sand` (S), `tile_slope` (H), `tile_lander` (L), `tile_target` (T) + sheet `tiles_sheet.png` 96×16 in the order **P R S H L T** (ready for a Godot TileSet).
  - Rovers seen from above, facing right (flip in Godot): `map_rover_open`, `map_rover_pressurized`.
  - States: `map_fog` (semi-transparent fog), `map_path_dot` + `map_path_arrow` (arrow to the right; rotate in Godot), `map_marker_target_0/1` (target marker, 2 floating frames), `map_cursor_0/1` (selection cursor, 2 pulsing frames).
  - Test with the real 10×8 map from the JSON: `art/_src/map_preview_1x.png` (board `art/_src/preview_map.png`; script `art/_src/make_map_tiles.py`).
- [x] **Crew portraits (4 × 2 expressions, draft v1)** → `art/crew/crew_<id>_normal.png` and `crew_<id>_worried.png` (48×48, transparent background; JSON ids) + sheet `crew_sheet.png` (2 columns normal/worried × 4 rows in the order vega, okoye, tanaka, duarte).
  - Look of each one (**fictional adult** characters): **Vega** gray hair and short beard · **Okoye** dark skin, afro hair · **Tanaka** black hair with bangs and glasses · **Duarte** auburn hair in a bun, earring.
  - **Suit stripe color (use the same on the field astronauts):** Vega red `#d6362f` (commander, as in the Apollo missions) · Okoye yellow `#f2c230` · Tanaka orange `#f07a1e` · Duarte green `#4fb04a`. Generic chest patch (no NASA logo).
  - Worried = eyebrows raised in the middle, mouth turned down, drop of sweat. Board: `art/_src/preview_crew.png`; script `art/_src/make_crew_portraits.py`.
- [x] **EVA astronauts (4 × 2 frames, draft v1)** → `art/crew/eva_<id>_0.png` / `_1.png` (16×16, side view facing right; flip in Godot) + sheet `eva_sheet.png` (2 columns = frames × 4 rows vega, okoye, tanaka, duarte). Stripes match the portraits.
- [x] **Event illustrations: 3 of 5 (Pedro's decision, ~3 pm)** → `art/events/event_<id>.png` 160×90, JSON ids: `event_dust_storm` (wall of dust approaching, crew heading back to the habitat), `event_solar_particle_event` (Sun with a flare, rain of particles, crew running to the blue shelter), `event_equipment_failure` (pressurized rover with a loose wheel, smoke, Tanaka with the wrench). **No illustration:** `medical_issue` and `relay_pass_missed` → use the affected crew member's *worried* portrait + alert card. Script `art/_src/make_eva_events.py`; board `art/_src/preview_eva_events.png`.
- ✅ **10 pm batch complete (~4 pm).**
- [x] **Title screen + logo (draft v1)** → `art/ui/title_bg.png` (320×180, **no text**: Martian sunset with a bluish glow around the Sun, mesas, Phobos/Deimos, habitat and the 4 astronauts watching the sunset) + `art/ui/logo_margin.png` ("MARGIN" logo with a green/yellow/red bar = margin) and `logo_margin_small.png`. Text ("A MARS MISSION DESIGN GAME", "CLICK TO START") is done in code, with a pixel font. Reference layout: `art/_src/title_mock_1x.png` (logo centered at y=22). Also covers the P1 item "game logo".
- [x] **Animations (74 animations, 47 entities) — ready for Godot 4, validated in Godot 4.3 (0 errors)** → `art/anim/`. **Read `art/anim/README.md`** (project setup, how to use, special cases and full list).
  - Format: **1 PNG sheet per animation** (frames side by side) + **1 `SpriteFrames` `.tres` per entity** (fps, loop and per-frame duration already set; paths `res://art/anim/...`) + `anim_manifest.json`.
  - **Essentials:** EVA astronauts ×4 (`idle`, `walk`, `work` collecting, `wave`), rovers on the map (`idle`, `drive` with dust), target marker, cursor, path arrow and dots.
  - **Portraits ×4:** `idle_normal`/`idle_worried` (blink), `talk_normal`/`talk_worried` (talk).
  - **UI:** 6 animated resource icons, warning icon, blinking critical bar, blinking alert card, **3 adjacency icons** (heat/flame, contamination, shielding/shield — P1 item).
  - **Screens:** animated title background (stars, sun glow, lights) + group of 4 walking + logo shine; 3 looping events; landing (ship descending with engine, landed, dust cloud on touchdown) + **`art/ui/landing_bg.png`** (landing screen background — the missing P0 item).
  - **Details:** target tile shine, lander light, fog, pulsing reactor, fan, charging battery, radio, anemometer, spectrometer, solar panel reflection; screen overlays `fx_dust_overlay` (dust, P1 item), `fx_alert_vignette`, `fx_sparkle`.
  - **Ready-made example scenes:** `art/anim/examples/title_screen_example.tscn` (title with the 4 walking) and `landing_example.tscn` (full landing sequence). Tested running in Godot 4.3.
  - GIF previews: `art/_src/anim_preview/`. Scripts: `art/_src/anims_*.py`, `make_anims.py`, `make_godot.py`. Full bundle: `art/_src/anim_bundle.zip`.
- [x] **Animations v2 (~6 pm):** GIF previews fixed (palette bug only in the GIFs; the PNGs were always right). ~~Redesigned astronaut (v3, dark visor)~~ → **Pedro preferred the original (gold visor): reverted everywhere** (static sprites, events and title identical to the approved ones). From the `pixel-art-sprites` skill (omer-metin, Apache-2.0, copy in `art/_src/skills_ref/`) only the **movement** improvements were kept: arm with outline (visible swing), sub-pixel idle, collecting with anticipation/strike/impact. `eva3.py` is kept only as history. **Move the astronaut at ~32 px/s** so it doesn't slide. Revalidated in Godot 4.3 (74 animations, 0 errors).
- [ ] Missing from P0: only the **report background**.
- ⏸️ **Uploading the art to the repository: postponed** (Pedro's decision, 2:50 pm). Everything stays in `art/` in the vault, already with the requested folder structure (`ui/`, `items/`, `crew/`, `map/`).
- ✅ **5 pm batch complete** (resources, items, UI, tiles). Next batch (10 pm goal): crew portraits, field sprites (astronauts), event illustrations.
- File names in **English** (matches the code).

## File delivery
- `art/` folder in the repository, subfolders `ui/`, `items/`, `crew/`, `map/`, `events/`.
- `art/CREDITS.md` file with **every** external source (pack, license, link) and whether any piece was made or processed with AI. **This list goes on the project page.**
