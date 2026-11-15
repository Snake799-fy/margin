---
tags: [nasa-space-apps, code, programmer, deploy]
---
# Code tasks (programmer) and deploy to GitHub Pages

> Game data: `game/data/game-data.json` (v1, to be tuned). Design: [[14 - Adjustment v1.1 (crewed, team of 2)]]. Art: [[15 - Art list (Pedro)]].
> Paths: the Godot project written below as `margin/` is the `game/` folder of the repository.

## 0. Stack decision (The programmer decides, not me)
The programmer picks **what he knows best**. Two options:
| Option | Advantage | Risk |
|---|---|---|
| **Godot 4.3+ (Web export)** | Already in the designer's doc; good for UI and map | Web export: needs **single-threaded** mode to run on GitHub Pages; large `.wasm` file; deploy to be tested early |
| **JavaScript/TypeScript** (Canvas/DOM, or Phaser) | Runs natively on the web, trivial deploy on Pages, easy to debug | Less of a "ready-made game engine" |
The game is basically **menus, a grid, a 10×8 map and logic**: either works well. If the programmer knows both equally, pure web has less deploy risk.

## 1. Work order (each item = something **playable**, even if ugly)
| # | Deliverable | Estimate | Done test |
|---|---|---|---|
| 1 | Load `game-data.json`; global state; **6-resource panel** that recalculates | 1.5 h | Changing a number in the JSON changes the bar |
| 2 | **Concept** and **Trade study** screens (clickable cards, effects applied) | 2 h | Choosing Super-Heavy changes capacity and cost |
| 3 | **7×5 grid**: click to place/remove (drag later), rotation, occupancy | 3 h | Pieces don't overlap; mass/cost/power add up |
| 4 | **Adjacency** (3 rules) with colored lines **before** confirming | 2 h | Container next to the drill shows a brown warning |
| 5 | **Review**: checklist (mass, cost, power, supplies ≥ stay+2, data) | 1 h | ❌ blocks launch; ⚠️ lets it through |
| 6 | **Landing**: explained probability, result | 1 h | Shows where the number comes from |
| 7 | **Surface**: 10×8 map, target choice, route cost (shortest path), EVA with pair and transport, sol by sol, ascent window countdown | 5 h | You can play 10 sols until lift-off |
| 8 | **Events** (4) + **improvisation** (visible list) | 2.5 h | Dust affects the solar panel |
| 9 | **Report**: score, cause chain (from the log), similar mission, "redesign" | 2 h | Same design = same score (deterministic) |
| 10 | Tutorial as contextual hints + texts in **English** | 1.5 h | Someone new gets it in 2 min |
**Total ≈ 21 h** ← more than the useful time. **That is why the order matters:** the cut-off point is item **9** (by Saturday 10 pm the 1→9 loop must exist, even without art). Item 10, event 5 and hot-seat only after that.

## 2. Code rules (to make review easier)
- **Everything comes from the JSON**: no balancing numbers inside the code.
- **One event log** (`log.push({sol, type, text, delta})`): the cause chain comes from it.
- **Seeded determinism**: `?seed=123` in the URL replays the game (helps testing and recording the video).
- Pure function `computeDesign(state) → {mass, power, cost, data, supplies, warnings[]}` used by the grid, the review and the report.
- Small, frequent commits; a `main` branch that is always playable.

## 3. Deploy to GitHub Pages (**do it before 5 pm today**)
1. Create a **public** repository (the free plan requires public). Suggested name: `margin-space-apps`.
2. Push a "Hello" `index.html` **today**, enable **Settings → Pages → Deploy from a branch → `main` / (root)** (or `/docs`).
3. Open the link `https://<user>.github.io/<repo>/` **in an incognito tab and on a phone**. Only then build on top of it.
4. If using **Godot**: export with *Thread Support* **off**, push all the export files to the repository and **add an empty `.nojekyll` file**. Test the first export **tonight**, not on Sunday.
5. If using JS: nothing special. Relative paths (`./art/...`), not absolute.
6. Repository with `README.md` (problem, solution, NASA data, how to play), `LICENSE` and `art/CREDITS.md`.
7. **Plan B** ready by Saturday night: a 30 s video of the working loop, in case the game fails live.

## 4. Final review (Claude)
- When a **public** repository exists, the programmer sends me the link (or adds the repo to the session). I read the code and the game, compare it with [[11 - Compliance matrix]] and return a **prioritized** list (blocks submission / improves the score / polish).
- **Suggested review windows:** Sat ~10 pm (full loop), Sun ~11 am (before the freeze), Sun ~1:15 pm (final submission check).
- No need to wait for the end: send the link at any time and I review whatever exists.

## 5. Code status (Sat 11/14, ~6:30 pm) — loop 1→7 playable
Claude wrote the whole game in GDScript, in new files inside `margin/`. The programmer's files (`maleta.gd`, `teste_de_maleta.gd`, `grid_container.gd`, `control.tscn`) **were not touched**. The new grid (`scripts/cargo_grid.gd`) uses the same fitting logic as `maleta.gd` ("maleta" = case), with 3 fixes: consistent 7×5 axes, 16 px cells and rotation without errors.
| File | What it does |
|---|---|
| `scripts/gs.gd` (autoload **GS**) | Data, design, all the rules (adjacency, review, landing, A* route, EVA, events, end of sol, report) |
| `scripts/ui.gd` | Interface shortcuts (label, button, card, bar) |
| `scripts/hud.gd` | Bar of the 6 resources (with tooltip) |
| `scripts/main.gd` + `scenes/main.tscn` | Screen switching |
| `scripts/screen_*.gd` | One screen per phase: concept, trade, cargo, review, landing, surface, report |
| `scripts/cargo_grid.gd` | 7×5 grid: click/drag, rotate (R or right-click), rule lines before dropping |
| `scripts/title.gd` | Click on the title → game |
Tested in **Godot 4.7** (same version as the programmer): a full game runs from the title to the report without script errors; screenshots checked.
**Missing (stretch):** Improvise button, map fog, sounds, hot-seat, credits screen on the title.
