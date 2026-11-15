# MARGIN — Every Gram Has a Cost

**NASA International Space Apps Challenge 2026 · Local event: Belo Horizonte, Brazil**
**Challenge 13: [Space Mission Design Game](https://www.spaceappschallenge.org/2026/challenges/space-mission-design-game/)**

## The challenge
Designing a space mission means balancing competing demands: mission objectives, spacecraft design, science instruments, launch vehicles, budget, power, mass, communications and orbital constraints. Students rarely get to experience a whole mission, from concept to operation. The challenge asks for an interactive game where players design, manage and simulate a complete space mission, make engineering decisions, manage limited resources and see how each choice shapes the mission's success.

## Our solution
MARGIN is a browser game about designing and flying a **crewed mission to Mars**. You are the Mission Director:

1. **Concept:** choose what the crew will study (the science objective drives everything else).
2. **Trade study:** choose the launch vehicle and launch window.
3. **Cargo:** pack the lander's cargo grid. Placement matters: heat, contamination and radiation shielding affect neighbouring items, and every item costs mass, power and budget.
4. **Review:** the crew reviews your design and points out risks.
5. **Landing.**
6. **Surface operations:** every sol you drive a scout robot across a fog-covered, randomly generated map and send the crew on EVAs, limited by suit time, power, food, data, communications and a fixed ascent window. Events (dust storms, solar particle events, equipment failures, medical issues, relay loss) grow out of your own design choices.
7. **Mission report:** the game explains *why* the mission succeeded or failed, so you can redesign and fly again.

The six resources the challenge asks for are always visible: **mass, power, budget, data, communications and time**. There are three difficulty levels, optional challenges and permanent upgrades. Game numbers are **simplified for play**.

## Play / run
- **Play in the browser:** https://snake799-fy.github.io/margin/ (desktop browser recommended)
- **Project demo (7 slides):** [`pitch/MARGIN_demo_7_slides.pdf`](pitch/MARGIN_demo_7_slides.pdf)
- **From source:** install [Godot 4.3+](https://godotengine.org/), *Import* `game/project.godot`, press **F5**.
- **Controls:** mouse for menus and the cargo grid · **WASD** move · **Q** switch robot/crew · **E** interact · **G** send the crew to the nearest flag · **TAB** crew details · **M** map · **N** mute · right-click removes an item from the grid.

## NASA resources used
The game's structure is built on the official challenge Resources:

| Resource | How MARGIN uses it |
|---|---|
| [Concept Maturity Levels (JPL)](https://dataverse.jpl.nasa.gov/dataset.xhtml?persistentId=hdl:2014/44299) | The design phases follow CML 1→4: idea → feasibility → trade study → point design. |
| [Design and Develop Science Missions (NASA)](https://www.nasa.gov/wp-content/uploads/2025/04/250323-design-and-develop-science-mission.pdf) | The four mission segments (launch, space, ground, user) shape the screens. |
| [Mission Design Lab (GSFC)](https://etd.gsfc.nasa.gov/capabilities/integrated-design-center/mission-design-lab/) | Its disciplines (power, thermal, structure, communications, cost, risk) become the component categories; the trade study has its own screen. |
| [A Learning Game About Telescopes (Webb)](https://science.nasa.gov/mission/webb/game-build-it-yourself/) | Inspiration: the objective constrains the instruments, and the result is explained at the end. |

The Mars map is hand-made and only *inspired* by a Jezero-style delta site; it is not real elevation data. No NASA logos are used.

## Team
| Name | Role | Contact |
|---|---|---|
| **Pedro Barbosa Silva Teixeira** | Art direction, game design decisions, playtesting | Pbst_@outlook.com |
| **Our student programmer** (under 18; name withheld per NASA Space Apps rules) | Programming: wrote most of the game code (Godot/GDScript), playtesting | — |

## Use of AI (declared)
We used **Claude (Anthropic, model Claude Opus 5.5)** throughout the hackathon. Everything it produced was directed, reviewed, playtested and approved by the team.

| Area | What the AI did | Why we used it |
|---|---|---|
| **Code** | Code review and bug fixing: it read the programmer's GDScript and pointed out and corrected bugs (e.g. the cargo grid's swapped axes, cell size and rotation, and a crash in the cargo screen). **Most of the game code was written by our student programmer.** | A two-person team with ~30 hours: a second pair of eyes on the code helped us find and fix bugs quickly. |
| **Game design** | Helped write the game design document, the game data (`game/data/game-data.json`), the challenge compliance matrix and the balancing (economy, difficulty levels). | To check our idea against every point of the official challenge text and keep the design consistent. |
| **Sprites and art** | Drew all pixel art and the 74 animations **in code** (Python scripts in `art-source/`), from our briefs and the 16-color MARGIN palette we chose together. Every asset was approved by Pedro. | We had no time to hand-draw every sprite; generating them in code kept the exact palette and lets anyone regenerate them. |
| **Music and sound** | Synthesized the chiptune music and sound effects in code (`game/tools/make_audio.py`). No samples. | No time or budget for an audio artist. |
| **Pitch, docs and translation** | Drafted the pitch slides from our script, this README, and translated our notes from Portuguese to English. | The whole repository must be in English for the global judging. |

Per-asset details: [`game/art/CREDITS.md`](game/art/CREDITS.md). Our full work log, including every AI session, is in [`notes/Log/`](notes/Log/). The log also records code drafts the AI suggested during the hackathon; the final game code was written by our student programmer.

### Main prompts we used
Summarized from our work log and translated from Portuguese.

| # | Prompt (what we asked) | Why |
|---|---|---|
| 1 | "Analyze our idea against the Belo Horizonte guide, the 5 judging criteria and the official challenge text. Should we change the idea or adjust it?" | To validate the idea before building. |
| 2 | "We are a team of 2 (art and code). Adjust the design: crewed mission, hosted on GitHub Pages." | To cut the scope to what two people can deliver. |
| 3 | "Generate the P0 art in code as pixel art; I approve each batch. Declare the AI use in the credits." | To get consistent art in time, with Pedro keeping the final say. |
| 4 | "Make lots of animations, from the most necessary to pure detail, each one separate and ready for Godot." | To make the game feel alive. |
| 5 | "The colors look swapped and the animations are weak." / "I prefer the old astronaut with the gold visor." | Art review: fixes and reverting to the approved design. |
| 6 | "Make a Godot project with everything ready so the programmer only has to code." | To let the programmer start right away. |
| 7 | "Read the programmer's code for the cargo grid and fix the bugs." | Code correction. |
| 8 | "I played and didn't understand the game: too much information on screen." | Playtest feedback → clearer screens, one big instruction per screen. |
| 9 | "Lock the mandatory items, add a cutscene for each kind of failure, and make exploration more dynamic (WASD, hidden information, beeping scanner, signal loss, events on foot)." | To make surface operations more fun. |
| 10 | "I always lose, the map is ugly and confusing, and the cargo sometimes gets stuck." | Balancing and bug fixing. |
| 11 | "Easy is too easy; medium needs to require playing well." | Difficulty levels. |
| 12 | "Redo the pitch slides with the game's real art." | The first slides did not match the game. |
| 13 | "Copy everything into the repository, organized, and translate it all into English." | Submission. |

## Repository layout
| Folder | Contents |
|---|---|
| `game/` | The Godot 4 project (scenes, GDScript, art, audio, fonts, game data). See `game/README.md`. |
| `docs/` | Web export served by GitHub Pages. |
| `art-source/` | Python scripts that generated the pixel art, animations and previews. |
| `pitch/` | Pitch deck (`MARGIN_pitch_EN.pptx`) and slide images. |
| `notes/` | Design notes, game design document and daily work log (Obsidian vault). |

## Credits and licenses
- Font: Press Start 2P (CodeMan38), SIL Open Font License 1.1 — `game/fonts/OFL.txt`.
- Animation method reference: open agent skill `pixel-art-sprites` by omer-metin (Apache-2.0) — `art-source/skills_ref/`.
- No third-party art, music or samples.
