# CLAUDE.md — NASA Space Apps BH 2026 (MARGIN)

Project: the game **MARGIN** for challenge 13 (*Space Mission Design Game*). Hackathon team in Belo Horizonte, Godot 4.
Local submission: **Sun 11/15 at 2:30 pm** · Pitch 3 pm · Global deadline **Sun 11/15 at 11:59 pm**.

## Where everything is (since Sun 11/15, ~1:40 pm)
Everything lives in the **repository `C:\Users\Snake\Documents\margin`** (GitHub `Snake799-fy/margin`). Every change is made here, so it all goes to the repo at once. The old `NASA Space Apps 2026` folder is just a copy and must not be edited anymore. **Everything in the repository is in English.**

| Before (vault) | Now (repo) |
|---|---|
| `margin/` (Godot project) | `game/` |
| notes, `CLAUDE.md`, `Contexto rápido.md`, `Diário/` | `notes/` (`Quick context.md`, `Log/`) |
| `art/_src/` | `art-source/` |
| `pitch/` | `pitch/` (English deck; the Portuguese deck stays in `archive/`) |
| `art/` (old copy of the art) | only `game/art/` counts; the old copy is in `archive/` (outside git) |
| `data/game-data.json` | `game/data/game-data.json` |
| Web export | `docs/` (GitHub Pages: Settings → Pages → `main` / `/docs`) |

In older notes, read `margin/...` as `game/...` and `art/_src/...` as `art-source/...`.

## How to work in this vault
1. At the start of a conversation, read only this file and `Quick context.md`. Don't read the whole vault.
2. Design source of truth: **`14 - Adjustment v1.1 (crewed, team of 2).md`** (wins over 09 where they conflict) + `09 - GDD v1.0` as the base. Data in `game/data/game-data.json`. Open them only if the task requires it.
3. Did a design decision change? Record it in the GDD, not just in the conversation.
4. At the end of each task, update (a) the topic note, (b) `Quick context.md`, (c) `Log/YYYY-MM-DD.md`.

## Note map
| Note | Purpose |
|---|---|
| 00 - Index | Vault entry point |
| 07 - Official challenge text and Resources | Full challenge text + official Resources list |
| 08 - Past winners and patterns | Research on global winners |
| 09 - GDD v1.0 | Design base |
| 10 - Game data tables | Numbers to become JSON (obsolete) |
| 11 - Compliance matrix | Requirement → where it is in the game |
| 12 - Revised plan and task split | Schedule (the per-person split is obsolete) |
| **14 - Adjustment v1.1 (crewed, team of 2)** | **Current design** |
| 15 - Art list (Pedro) | Art tasks and priorities |
| 16 - Code tasks (programmer) and deploy | Code order, GitHub Pages, review |
| game/data/game-data.json | Game data |
| 13 - Project page, pitch and demo | Submission drafts |
| 01–06 | History of the first analysis (partly superseded) |

## Team
Pedro = art · the programmer = code · Claude = design, data and final review. Hosting: GitHub Pages.

## Fixed rules
- Everything in the repository in **English** (notes, page and game texts).
- Never put the face, voice or name of anyone under 18 in the demo.
- Declare all use of AI; AI images/videos watermarked; no NASA logos.
- Cite the source and version of all data. MOLA/Mars Trek are **not** in the Resources tab: use the official Resources as the central structure.
- Game numbers are simplified; the real anchors must be checked at the source before publishing.
