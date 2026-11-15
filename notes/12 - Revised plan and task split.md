---
tags: [nasa-space-apps, plan]
replaces: "[[03 - 25-hour plan]]"
---
# Revised plan (from Sat ~2 pm)

> ⚠️ **Real team = 2 people** (Pedro: art · the programmer: code · Claude: design, data and review). The 6-role split below is **obsolete**; see [[15 - Art list (Pedro)]] and [[16 - Code tasks (programmer) and deploy]]. The time milestones (freeze Sat 10 pm, submit Sun 2:30 pm) still apply.

## Split per person (adjust to names)
| Person | Production role | Systems (GDD §15) |
|---|---|---|
| Dev 1 | Core and data | `GameState`, `DataDB`, JSONs, `DesignValidator`, 6-resource panel |
| Dev 2 | Grid | `GridBay` (place, rotate, adjacency, lines, impact diagram) |
| Dev 3 | Operations | `SurfaceSim`, 12×8 map, sols, action queue, `EventManager` |
| Game designer | Design and balancing | Tables ([[10 - Game data tables]]), events, texts, cause chain, playtest |
| Art/UI | Visuals | Palette, map tiles, piece icons, console UI, 3–4 Navcam images, launch animation |
| Communication/data | Submission | MOLA→JSON script (if no dev can), English page, slides, video, references, AI declaration |

With fewer people: Dev 1 takes simplified operations (no fog, 8 sols) and the art uses a CC0 pack.

## Schedule
| When | Verifiable deliverable |
|---|---|
| Sat 2–3 pm | Everyone reads GDD v1.0. Decide: title, number of players in the demo, names for the roles. Git repository + Godot project created. v1 JSONs copied from the tables |
| Sat 3–4 pm | 6-resource panel + Concept and Trade Study screens working (no art) |
| **Sat 4 pm** check-in | Sentence ready: *"Real missions require trading mass for science, power for time; our game puts 4 students at that table."* |
| Sat 4–7 pm | Grid with 3 adjacency rules; Design review with checklist; map of 1 site generated from MOLA |
| Sat 7–10 pm | Sols with action queue + 3 events + simple report. **End-to-end loop playable** |
| **Sat 10 pm** | 🧊 Feature freeze. Record a backup video of the loop (even if ugly) |
| Sat night | Sleep. Optional art |
| Sun 9–10:30 am | Playtest with 2 outsiders (time it: do they get it in 2 min?). Fix only clarity |
| Sun 10:30 am–12 pm | Final art, sounds, 2nd site, 4th event, cause chain, similar mission |
| Sun 12–1:15 pm | Web export → itch.io; test on another PC and in an incognito tab; backup Windows build |
| Sun 1:15–2:15 pm | English page, 30 s video **or** 7 slides, references, AI declaration |
| **Sun 2:30 pm** | **Submit for Judging** |
| Sun 3 pm | Pitch ([[13 - Project page, pitch and demo]]) |
| Sun until 11:59 pm | Improve page/video and resubmit (counts for global) |

## Cut order if late
1. CubeSat scenario → 2. Compare attempts → 3. 3rd site → 4. Secret personal objectives → 5. Navcam → 6. Adjacency rule 5 → 7. Fog of war.
**Never cut:** 6-resource panel, grid with adjacency, launcher check, roles with sign-off, 1 event, report with "why".
