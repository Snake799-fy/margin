# Quick context (updated: Sun 11/15, ~2 pm)

## State
- Game **MARGIN**: mission design + surface operations on **Mars, CREWED** (4 fictional astronauts; the player is the Mission Director). Current design: note **14**; base: note 09; data: `game/data/game-data.json`.
- **Team of 2:** Pedro = art · the programmer = code · Claude = design, data and final review.
- Hosting: **GitHub Pages** (public repository `Snake799-fy/margin`).
- **Godot project in `game/`** (open `game/project.godot` in Godot 4.3+): art + 74 animations, UI theme (Press Start 2P font, 9-slice buttons/panels/cards), map TileSet, `data/game-data.json`, animated title as the main scene, UI demo, Web export preset. See `game/README.md`.
- **CODE: loop 1→7 playable** (Claude, Sat ~6:50 pm). 13 scripts in `game/scripts/` + `scenes/main.tscn`, autoload `GS` (rules), title → game. Tested in Godot 4.7 without errors. The programmer's files intact. Details: note 16 §5; new rules: note 14 §12.
- **Sound + clarity (~8:30 pm):** chiptune soundtrack and 10 effects in `game/audio/` (AI, declared); briefing screen; 1 big instruction per screen; live task list on the grid; step hints on the surface. Pedro had found the game confusing.
- **Sun 10:55 am:** tighter economy (1,800 M$), science goal 27/35, random map, 9 cargo events, boulders and cracks. Note 14 §17–19.
- **Sun 9:35 am:** several EVAs per sol (8 h of suit time per person), map with marks (M), trade, cargo and report screens redone. Note 14 §16.
- **Installations (~9:35 pm):** robot charger and relay beacons on the grid; automatic walk back; sound per event; key bar. Note 14 §15.
- **Direct control (~9:40 pm):** WASD + Q (robot or crew) + E to interact; EVA starts when leaving and ends when returning to the ship; moving dust devils; right-click removes an item from the grid. Note 14 §14.
- **Open world (~9:15 pm):** mandatory items locked; 32×20 surface with fog, WASD robot with a beeping scanner, clicked route for the crew, suit time, events on foot, robot signal loss, TAB for details; final cutscene per outcome type. Note 14 §13.

## Decisions taken
1. Crewed (tension and emotion), instead of a robotic rover. Fixed ascent window + radiation + crew condition create the pressure.
2. Team of 2 → cuts: no multiplayer (hot-seat is a stretch), only 1 site, no launch animation, 3 adjacency rules.
3. 7×5 lander cargo grid with rules: heat, contamination, shielding (water next to the shelter).
4. Phase structure follows the official Resources (CML, 4 segments, Mission Design Lab).
5. MOLA/Mars Trek data out of the MVP (not in the Resources tab); map inspired by Jezero, hand-made (later randomly generated).
6. P0 art generated **in code by Claude** (pixel art, AI declared in `game/art/CREDITS.md`), approved by Pedro. **MARGIN palette v1 (16 colors)** in `game/art/palette/`.

## State Sun 11/15 ~11:30 am
- Game with goals per difficulty, scarce food, 10 combos, side jobs, juice, challenges and tokens with permanent upgrades (note 14 §21–26).
- Budget: easy 1800, medium 1700, hard 1580.

## State Sun 11/15 ~2 pm — everything in the repository, in English
- **Everything was copied into the repo `Documents\margin`** (GitHub `Snake799-fy/margin`). From now on, **every change is made there**. The `NASA Space Apps 2026` folder is just an old copy (don't edit).
- Structure: `game/` (Godot project) · `notes/` (this vault, in English) · `art-source/` (art scripts) · `pitch/` (English deck) · `docs/` (Web export for Pages) · `archive/` (zips, old art, Portuguese originals; **outside git**). `README.md` in English at the root, with the challenge, team, AI use and prompts.
- The Web export now goes to `docs/` (`export_presets.cfg`); `docs/.nojekyll` created. Enable Pages: Settings → Pages → `main` / `/docs`.

## Open items
- **URGENT:** Web export + GitHub Pages (The programmer); commit + push; put the Pages link in the README.
- The programmer: reopen Godot through `game/project.godot` (if he edited the old folder after 1:40 pm, copy again).
- Choose and add a `LICENSE`.
- Pitch: insert the demo video on slide 8; rehearse with a timer.
- Claude has not read the Resources documents yet (only the tab descriptions): CML, Mission Design Lab, *Design and Develop Science Missions*, CubeSat 101.
- Check real anchors (CHAPEA, architecture concepts, surface fission) before publishing.
- Update the Project instruction: folder `Documents\margin`, notes in `notes/`, start with `CLAUDE.md` and `Quick context.md`; design source of truth: note 14 + 09.

## Milestones
Loop playable **Sat 10 pm** ✅ → feature freeze → Claude reviews Sat ~10 pm, Sun ~11 am and ~1:15 pm → submit **Sun 2:30 pm** → global Sun 11:59 pm.
