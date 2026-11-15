---
tags: [nasa-space-apps, submission, pitch]
---
# Project page, pitch and demo

> ⚠️ The page draft below was written for the early robotic-rover version. The current, up-to-date project description is the repository `README.md`.

## Page draft (adjust to what was actually built)

**Project name:** MARGIN — Every Gram Has a Cost

**High-level summary:**
MARGIN is a cooperative mission design game for 1–4 players. The team takes a Mars rover mission from a science question to surface operations: they define the objective, derive requirements, run a trade study (landing site, power source, communications, launch window, launch vehicle), and lay out the rover in a grid where component placement matters: heat, radio interference and contamination affect each other. Then they fly it. Every sol they plan commands, limited by power, data and communication windows, and face events that grow out of their own design choices. A final report scores the mission and explains *why* it succeeded or failed, links the design to a real NASA mission, and invites the team to redesign and fly again.

**How it works:** 7 phases following JPL's Concept Maturity Levels and the four mission segments (launch, space, ground, user). Six resources are always visible: mass, power, budget, data, communications and time. Four roles (Principal Investigator, Systems Engineering, Instrument Science, Operations & Communications) must all sign off before the mission advances, and conflicting priorities trigger negotiation cards.

**Benefits:** Students rarely experience a whole mission from concept to operation. MARGIN makes the trade-offs tangible, runs in a browser, and is built for four students sharing one computer in a classroom.

**Tools:** Godot 4 (GDScript), Python (data prep), Aseprite/[tool], itch.io.

**NASA resources used:** Design and Develop Science Missions (mission segments); JPL Concept Maturity Levels (game phases); GSFC Mission Design Lab (spacecraft disciplines and trade-study structure); A Learning Game About Telescopes (objective → instrument constraints, real-mission comparison); CubeSat 101 (tutorial scenario, if built); NASA Mission Viz (cruise visualization reference); MOLA elevation data from the PDS (surface maps) [cite exact product]. Real mission facts (Sojourner, Spirit, Opportunity, Curiosity, Perseverance) anchor the numbers, which are simplified for play.

**Use of AI:** [Declare exactly: e.g., "Claude was used to brainstorm and review the design document and to draft text; all code/art were …". Any AI-generated image carries a visible watermark.]

**References:** [list every dataset, page, asset pack (with license), font and sound.]

## Pitch (5 min, local)
1. **Problem (30 s):** "People who study space see orbits in one place, rockets in another, instruments in another. Nobody sees the whole mission, and NASA says so in the challenge itself."
2. **Live demo (2 min):** choose an objective → put the RTG next to the spectrometer (red line, data −30%) → incompatible launcher → approve → dust storm → report with the cause chain.
3. **Data and science (1 min):** CML phases, 4 segments, real MOLA terrain, real mission anchors, "simplified" stated openly.
4. **Collaboration and impact (45 s):** 4 roles, classroom, browser, free.
5. **Next step (45 s):** CubeSat scenario, other destinations (Moon, Europa), teachers, PT-BR.

## Demo for the page (pick 1 format)
**30 s video (PT audio, EN subtitles, no minors):**
| Time | Image | Subtitle |
|---|---|---|
| 0–4 s | Title + "Every gram has a cost" | — |
| 4–10 s | Drag the radio next to the spectrometer: purple line, data −40% | *Where you place a part matters.* |
| 10–15 s | Red mass bar: "launcher incompatible" | *Mass, power, budget, data, comms, time.* |
| 15–22 s | 4 "Approve" buttons; Mars map; storm | *Four roles. One mission. Real trade-offs.* |
| 22–30 s | Report: cause chain + "Redesign & fly again" | *Learn why your mission succeeded or failed.* |

**Or 7 slides:** 1 Problem · 2 Solution (phases) · 3 The grid · 4 Operations · 5 Report and learning · 6 NASA resources used · 7 Team (no minors) and next steps.

## Pitch slides (Sun 11/15, ~11:15 am)
- Canva deck, 11 slides, 16:9, in Portuguese, following the 5-min script: https://www.canva.com/d/k3Ol2TZTKH-zkOq
- Slide 8 = DEMO, with a "DEMO VIDEO HERE" rectangle to paste the 30 s video.
- No NASA logos; AI declared on the last slide.
- To adjust in Canva before the pitch: slide 5 (add CML/JPL, 4 segments, real events, CHAPEA, numbers with sources) and slide 10 (next steps: 2–4 hot-seat, CubeSat tutorial, GMAT, more sites). The generator replaced these items with generic text.

### Redone in the game's style (~11:30 am)
- The Canva-generated deck was discarded: its art (realistic Mars) wasn't the game's and sold something MARGIN isn't.
- New deck: `pitch/MARGIN_pitch.pptx` (11 slides 1920×1080). Uses only the real art (`art/`): title screen, logo, palette v1, Press Start 2P font (with fixed uppercase accents), 9-slice panels, portraits, resource icons, 7×5 grid built with the items, map built with the tiles, event illustrations. Speaker notes = script.
- Slide 8: empty "DEMO VIDEO HERE" panel to drop the video on top.
- Slides 5 and 10 already with the right content (CML, 4 segments, CHAPEA; hot-seat, CubeSat, GMAT, more sites).
- PNGs in `pitch/png/`; editable source (HTML + scripts) in `pitch/slides_fonte.zip` (kept locally, not in the repository).
- Automatic upload to Canva was blocked by the network: import the .pptx into Canva manually.
- The Portuguese deck used for the local pitch is kept locally; the repository has the English version `pitch/MARGIN_pitch_EN.pptx`.
