---
tags: [nasa-space-apps, gdd, design]
version: 1.0
date: 2026-11-14
replaces: creative direction v0.1 (keeps the pillars; changes the focus)
---
# MARGIN — Game Design Document v1.0

> ⚠️ **Update 11/14 ~2 pm:** the team decided on a **crewed mission**, a team of 2 people and GitHub Pages. Where they conflict, [[14 - Adjustment v1.1 (crewed, team of 2)]] wins. The robotic rover, 4 playable roles and hot-seat sections of this document are **superseded**.

> **Working title:** **MARGIN** (*Every gram has a cost*). Alternatives: *Sol Plan*, *Payload*, *Launch Window*.
> **Identity sentence (kept from the original doc):** *On Mars, the biggest risk isn't what you'll find. It's discovering, too far from home, what you should have brought.*
> **One-sentence pitch:** *A co-op mission design game where up to 4 players design a real-style Mars rover mission, from science goal to launch to surface operations, and live with every gram, watt and dollar they chose.*

---

## 0. What changed from doc v0.1, and why

| v0.1 (game designer) | v1.0 | Reason (official challenge text and winners) |
|---|---|---|
| Crewed field trip from a habitat | **Complete robotic science mission to Mars (rover)**, from concept to operation | The challenge asks for objective, spacecraft, instruments, launcher, orbit, budget, power, mass, communications and lifetime. The Resources are all about **science mission design** |
| Crew of 3 characters with functions | **Crew = the players (1 to 4)**, each with a role | The challenge asks for collaboration of up to 4 people with roles and negotiation, several times |
| Grid case with adjacency | **Spacecraft/rover bay on a grid with adjacency** (thermal, interference, contamination, power) | Keeps the designer's best idea and turns it into real engineering (thermal layout, electromagnetic compatibility, planetary protection) |
| First-person dungeon crawler | **Top-down grid surface operations by "sols"** + one pixelated "Navcam" image per sector | Keeps step-by-step exploration and decisions at a fraction of the cost. Real rovers are operated this way: daily plans sent from Earth |
| 3 resources (O₂, power, integrity) | **The challenge's 6 resources:** Mass, Power, Budget, Data, Communications, Time, + Integrity during operations | Explicit list in the challenge |
| Improvisation with a cost | **Kept:** contingencies during operations use margins and reserves | Designer's pillar; real concept of engineering margin |
| 1 elevation dataset | **Official Resources as structure** (CML, MDL, 4 segments, CubeSat 101, Webb game) + MOLA elevation as **extra map data** | Global eligibility requires a resource from the Resources tab |
| Evaluation on return | **Report + post-mission analysis ("why") + comparison with real missions + "Redesign and fly again"** | Explicitly asked in the challenge; PureFlow pattern |

**v0.1 pillars kept:** preparation is gameplay; the environment is the challenge; resources with more than one function; improvising has a cost; the crew is the player's responsibility; science holds the world together.

---

## 1. Overview

**Genre:** mission design game + operations simulation, local co-op (*hot-seat*) for 1 to 4 players, pixel art, no combat.
**Platform:** Godot 4 (Web/HTML5 export playable in the browser + backup Windows build).
**Audience:** students aged 12+ and beginners (*Beginner/Youth* and *Intermediate* levels), with an advanced mode.
**Length:** 15–25 min per game; 3 min tutorial.
**Fantasy:** being the team of a NASA Mars mission, from a sketch on a napkin until the rover sends its last photo.

**Promise to the player:** *every choice shows up again later.* The instrument you didn't bring is missed on sol 9. The cheap solar panel dies in the storm. The radio stuck next to the magnetometer ruins the data.

---

## 2. Game structure (aligned with the official Resources)

The game follows JPL's **Concept Maturity Levels (CML)** and the **4 mission segments** of the *Design and Develop Science Missions* document.

```
PHASE 1  CONCEPT (CML 1–2)        → science objective + requirements
PHASE 2  TRADE STUDY (CML 3)      → landing site, power, comms, window, launcher
PHASE 3  POINT DESIGN (CML 4)     → grid bay: instruments and subsystems (adjacency)
PHASE 4  DESIGN REVIEW            → automatic checks + sign-off by the 4 roles
PHASE 5  LAUNCH, CRUISE, EDL      → short sequence with 1–2 events
PHASE 6  SURFACE OPERATIONS       → 12–15 sols on a top-down grid (the "crawler")
PHASE 7  REPORT AND ANALYSIS      → score, cause chain, similar real mission, redesign
```

Each phase shows the active **segment** (launch, space, ground, user) and the current **CML** at the top. It is a visible way to show the use of the Resources.

---

## 3. Roles (collaboration for 1 to 4 players)

Based on the responsibilities named in the challenge and the Mission Design Lab disciplines.

| Role | Responsible for | Decides | Gauge they "defend" |
|---|---|---|---|
| **Principal Investigator (PI)** | Science objective and budget | Objective, requirements, target priority in operations | **Budget**, **Science value** |
| **Systems Engineering** | Spacecraft, mass and power | Power source, batteries, structure, bay layout | **Mass**, **Power** |
| **Instrument Science** | Payload | Instruments, operating modes, data quality | **Data (generation)** |
| **Operations & Communications** | Ground segment, launch and daily plan | Window, launcher, antenna, plan for each sol, downlink | **Communications**, **Time** |

**With fewer players:** with 1 player, they switch "hats" (role tabs); with 2, each has 2 roles; with 3, the PI also takes Operations.

**Collaboration mechanics (cheap to implement):**
1. **Sign-offs:** each role only edits its own part. To advance a phase, **all 4 roles sign** ("Approve" button). Anyone can request a change.
2. **Flagged conflicts:** the game detects conflicts and shows a "Negotiation" card, e.g. *"Science wants the advanced spectrometer (+18 kg). Engineering has a 4% mass margin."* The options come with a visible cost.
3. **Priority cards:** at the start, each role gets 1 secret or open personal objective (e.g. Ops: "finish with ≥20% data margin"). Individual and collective bonuses can conflict, which creates real negotiation.
4. **Collaboration score:** decisions approved without rework, conflicts resolved, personal objectives met.

> Online multiplayer is **out** of scope. *Hot-seat* on the same machine meets "collaboration for up to 4", is demonstrable at the pitch and fits in 25 h.

---

## 4. The 6 resources (panel always visible)

Fixed top bar, with current value / limit and **margin %**:

| Resource | In-game unit | Limit comes from | Consumed by |
|---|---|---|---|
| **Mass** | kg | Launcher capacity for the chosen trajectory | Each component |
| **Power** | W (peak) and Wh/sol | Power source × site × season × dust | Instruments, heaters, radio, driving |
| **Budget** | M$ (millions) | Mission class chosen by the PI | Components, launcher, operations per sol |
| **Data** | Mb generated/stored | On-board memory | Instruments |
| **Communications** | Mb/sol of downlink | Antenna × relay × windows | Sending data |
| **Time** | sols of lifetime (+ development deadline) | Power source, degradation, events | Each sol |

During operations, **Integrity** (0–100%) of wheels, radio and instruments is added.

**Margin visual rule:** green ≥ 15%, yellow 5–15%, red < 5%. A negative margin blocks approval. The short explanation appears in the game: *"Engineers keep a margin because the real spacecraft always weighs more than planned."* (The 15% threshold is a game rule, not an official NASA number.)

---

## 5. Phase 1 — Concept (CML 1–2)

**Screen:** mission board with 3 objective cards (the PI chooses; the others can comment).

| Objective | Science question | Derived requirements (the game generates them) | Similar real mission |
|---|---|---|---|
| **A. Signs of ancient life** | "Was there life in an ancient Martian lake?" | Camera + spectrometer + sample collection/caching; site with lake sediments | Perseverance |
| **B. Habitability and ancient climate** | "Did Mars ever have conditions for life?" | Camera + chemistry lab or spectrometer + weather station | Curiosity |
| **C. Prepare for humans** | "Where would an astronaut find water and take shelter?" | Subsurface radar or neutron detector + weather station + radiation meter | Precursor mission concept |

Each objective has **1 primary goal + 2 secondary goals**, with points. The game shows generated **"Level 1 requirements"** (e.g. *"Must analyze ≥3 sedimentary rocks and send ≥120 Mb of data to Earth"*). This way the player sees the **science → requirement → engineering** path the Resources describe.

**Mission class = budget** (PI's choice):
- *Small* (low cost, few components): easy to close, limited science.
- *Medium*: balanced (default).
- *Flagship*: lots of possible science, but mass becomes the bottleneck.

---

## 6. Phase 2 — Trade Study (CML 3)

One screen with **5 architecture decisions**. Each option shows pros and cons **and the numeric effects before confirming**. This is the "there is no perfect solution" screen.

### 6.1 Landing site (3 real options)
| Site | Why it's good | Why it's hard |
|---|---|---|
| **Jezero Crater** (~18°N) | Ancient lake delta: great for objective A | Rocky, uneven terrain; less sun than at the equator |
| **Gale Crater** (~5°S) | Sedimentary layers: great for B; near the equator = more sun | Slopes on the way to the targets |
| **Meridiani Planum** (~2°S) | Flat plain, easy landing and lots of sun | Less rich science for A |

Each site's operations map is a simplified cut-out of the **real terrain (MOLA)**: elevation → travel cost and risk per sector. Science rule shown in the game: **lower sites have more atmosphere above them to slow the landing**, and **closer to the equator means more sun and less cold**. Exact elevation and latitude must be extracted from MOLA data and recorded in [[10 - Game data tables]].

### 6.2 Power source
| Option | Effect |
|---|---|
| **Solar panels** | Cheap and light; power depends on latitude, season and **dust** (drops a lot in a storm); needs a big battery for the night |
| **RTG (radioisotope generator)** | Expensive and heavy; constant power day and night, independent of dust; **produces heat** (effect on the grid) |

### 6.3 Communications
| Option | Effect |
|---|---|
| **Direct-to-Earth antenna only (high gain)** | More mass and power; 1 window per sol; independent of orbiters |
| **UHF radio via relay orbiter** | Light; more data per sol, but only during orbiter passes (windows in the sol plan) |
| **Both** | Redundancy; more mass and cost |

### 6.4 Launch window (orbit/trajectory)
Earth–Mars windows repeat every ~26 months. Two options:
| Window | Effect |
|---|---|
| **Window A (nominal)** | More energy required from the launcher (less mass possible); arrives in a season **without dust storms** |
| **Window B (late)** | Longer trip, the launcher allows more mass; arrives close to the **dust storm season** (dust event more likely) |
*Stretch:* compute both trajectories in **GMAT** and use the real trip durations.

### 6.5 Launcher (compatibility check)
Three generic classes (Light, Medium, Heavy), with capacity for a Mars trajectory and cost. Total mass (rover + descent stage + cruise, simplified as a multiplier) > capacity → red warning: *"Incompatible: the launcher cannot put this mass on the chosen trajectory."* This is the check the challenge asks for.

---

## 7. Phase 3 — Point Design: the grid bay (CML 4)

**The creative heart, inherited from the designer's case.**

### 7.1 The grid
- Rover bay: **6×5** grid (Small: 5×4; Flagship: 7×6).
- Components are pieces from 1×1 to 2×3, dragged and rotated.
- Categories (Mission Design Lab disciplines): **Power, Battery, Communications, Computer, Thermal control, Instruments, Sampling, Structure**.
- Each piece has: mass, cost, power, data/use, science value, **adjacency tags**.
- **Simple** and **Advanced** versions of several components (the challenge suggests this for difficulty).

### 7.2 Adjacency rules (easy to read, grounded in reality)
Colored lines appear between pieces while the player drags. **The effect appears before dropping.**

| # | Rule | Color | In-game effect | Real concept taught |
|---|---|---|---|---|
| 1 | **Heat:** RTG or hot component next to battery/computer | 🟧 | +good: reduces heater power at night (−X Wh/sol) | Thermal control uses waste heat |
| 2 | **Unwanted heat:** hot source next to a sensitive instrument/sample | 🟥 | −data quality and −sample value | Detectors and samples need thermal stability |
| 3 | **Interference:** radio/transmitter next to a sensitive instrument (magnetometer, spectrometer) | 🟪 | −data quality of that instrument | Electromagnetic compatibility |
| 4 | **Contamination:** drill/lubricated parts next to the sample tubes | 🟫 | −science value of the samples | Planetary protection and sample cleanliness |
| 5 | **Power bus:** high-draw component touching the battery/source | 🟩 | −losses (small power gain) | Short cabling = less loss and less mass |

For the MVP, implement **3 rules (1, 3, 4)** and add 2 and 5 if there is time.

### 7.3 Live panel
Next to the grid, the 6 bars recalculate on every move. Plus an **"Impact diagram"**: when a piece is selected, arrows show everything it affects (mass↑, cost↑, data↑, power↓). It is the challenge's own "more capable instrument" example turned into interface.

---

## 8. Phase 4 — Design review

A screen with an automatic checklist (simulates a real review):
- ✅/❌ Mass ≤ launcher capacity (margin ≥ 5%)
- ✅/❌ Cost ≤ budget
- ✅/❌ Average power ≥ expected consumption on a typical sol
- ✅/❌ Data generated per sol ≤ downlink per sol + memory
- ✅/❌ Level 1 requirements covered (required instruments present)
- ⚠️ Bad adjacency warnings

Each ❌ explains **why** in 1 sentence. The 4 roles sign. You can **launch with ⚠️ warnings** (conscious risk), but not with a mass or cost ❌.

---

## 9. Phase 5 — Launch, cruise and landing (EDL)

Short animated sequence (30–60 s), with **1–2 decisions**:
1. **Launch:** pixel art animation; summary "mass launched X kg / capacity Y kg".
2. **Cruise:** simple Earth → Mars map with the trajectory (visual reference to **NASA Mission Viz**, with a link). Possible event: *"Star tracker failure: use power reserve or time reserve?"* (improvisation).
3. **EDL ("7 minutes of terror"):** the chance of a perfect landing depends on the **site elevation** and the **mass margin**. It is never pure luck: the game shows the probability and where it comes from before rolling. Possible result: landing X sectors from the planned point (affects operations).

---

## 10. Phase 6 — Surface operations (the "crawler")

### 10.1 Map
- **Top-down** grid of **12×8 cells** derived from the site's real terrain (MOLA, simplified).
- Each cell: elevation → **slope** relative to neighbors → power cost and wheel risk.
- Terrain types (labeled): plain, rocks, soft sand, slope, **science target** (icon).
- **Fog of war:** cells are revealed when you get close or use the camera.
- On entering a sector, a **static pixelated "Navcam" image** appears (1 per terrain type). It is the legacy of the designer's first-person view, at a fraction of the cost.

### 10.2 The sol (turn)
Real rovers are not driven in real time: the signal takes ~4 to ~24 min between Mars and Earth. So **the team plans the sol, uplinks it and watches the result**. This is taught in the tutorial.

Each sol:
1. **Briefing:** power forecast (sun × dust), communication windows (orbiter passes or direct window), memory state and integrity.
2. **Planning (all roles):** queue of up to **6 actions** (cards):
   - Drive 1 cell (power ∝ slope; risk in sand or rock)
   - Photo/panorama (reveals cells, generates data)
   - Analyze target with instrument X (power, time, data, science)
   - Collect sample (drill; needs a free tube)
   - Send data (uses the communication window)
   - Hibernate/heat (saves power and protects the battery)
3. **Animated execution** step by step, with events.
4. **Sol summary:** resources before → after, science gained.

The mission lasts **12–15 in-game sols**, representing the primary mission (in-game, "1 sol = weeks of operation"; the game text must make it clear this is a simplification).

### 10.3 Contextual events (5 in the MVP; never random without context)
| Event | Trigger (depends on choices) | Options (visible cost) | Real basis |
|---|---|---|---|
| **Dust storm** | Window B and/or season; worse with solar | Hibernate (lose sols), reduce instruments, carry on with battery risk | Opportunity was lost in the 2018 global storm |
| **Damaged wheel** | Driving over rocks without camera/planning | Longer route, drive backwards, accept −integrity | Curiosity had holes in its wheels on sharp terrain |
| **Stuck in soft sand** | Entering sand without a prior photo | Spend 2 sols and power to get out, abandon the route | Spirit got stuck in sand in 2009 |
| **Missed relay pass** | UHF only + weighted bad luck | Keep data (memory fills up), prioritize data | Operations depend on orbiter passes |
| **Unexpected discovery** | Exploring a sector off the route | Detour (time and power) for bonus science | Real missions change plans for findings |

### 10.4 Improvisation (designer's pillar, kept)
When the ideal resource is missing, the **"Improvise"** button appears, with a **visible list** of what can be spent:
- use **margin** of power, mass already paid for, or time;
- **turn off an instrument** for good (lose its science, gain power);
- **safe mode** (lose 1 sol and protect the spacecraft);
- **reuse a redundant component** (if the player brought redundancy).

The game shows the range of consequences, asks for confirmation and records it in the mission log. Improvising is never always the best option.

### 10.5 End of operations
By time (last sol), by loss (power at zero with a cold battery, integrity 0) or by team decision ("end and make sure the data is sent").

---

## 11. Phase 7 — Report, post-mission analysis and iteration

1. **Final score (0–100)**
   - Science — 40 (primary 20, secondary 10, data quality 10)
   - Engineering — 25 (final margins, integrity, good adjacencies)
   - Resources — 20 (budget used vs. available, data sent / generated)
   - Team — 15 (consensus, conflicts resolved, personal objectives)
   - Badge: **Full success / Partial success / Mission lost**
2. **Cause chain** (the "why" the challenge asks for): 3 automatic cards linking decision → consequence, e.g.:
   *"You chose solar panels + Window B → arrived in the storm season → power dropped 70% on sol 6 → 3 sols in hibernation → only 1 of 3 targets analyzed."*
3. **Similar real mission:** "Your design looks like **Perseverance** (2020): RTG, sample collection, Jezero." A short card with what the real mission did (idea taken from the Webb game, which is in the Resources).
4. **Buttons:** **Redesign and fly again** (back to Phase 2 with the design saved) · **Compare with the previous attempt** (side-by-side table) · **Copy design code** (string to share the design).

---

## 12. Scenarios and difficulty

| Scenario | Purpose | Status |
|---|---|---|
| **"CubeSat First Flight" tutorial** (3 min) | Teaches mass, power, data and orbit with 4 pieces on a 3×1 grid (3U CubeSat); choice between 2 low orbits (e.g. coverage vs. lifetime). Based on **CubeSat 101** | **P2** (only after the MVP) |
| **Mars rover** | Main scenario | **MVP** |
| **Quick challenge** | Pre-built mission with 1 hidden mistake; the team has 2 min to find it | P3 |

Difficulty: **Explorer** (simple pieces, given margins, hints) · **Engineer** (default) · **Flight Director** (advanced pieces, more events, no hints).

---

## 13. Interface (essential screens)
1. Title + number of players and roles
2. Concept (objective cards + class)
3. Trade Study (5 decisions with pros and cons)
4. Grid bay + 6-resource panel + impact diagram
5. Design review (checklist + sign-offs)
6. Launch/cruise/EDL
7. Operations (map + action queue + panel + Navcam)
8. Event (short description, options, costs, risk)
9. Report (score, cause chain, real mission, buttons)

**Readability (from the original doc, kept):** at any moment the player can answer: *How is the mission doing? How much is left? What can I do? How much does each option cost?*

**Accessibility:** colors always with an icon and text (never color alone); readable pixel font ≥ 16 px; all game text in **English** (global judges) with a **PT-BR** option if time allows; keyboard shortcuts.

---

## 14. Art and audio
- 320×180 pixel art scaled up (integer scale), restricted palette of ~16 colors: Mars ochres and rusts + functional alert colors (green/yellow/red/purple).
- "Mission control console" UI style.
- **No NASA logos or symbols** (guide rule).
- Art and audio packs only with a free license (CC0, e.g. Kenney) and **listed in the references**. AI-generated images carry a visible watermark and are declared.
- Audio: console beeps, muffled wind, distinct alerts for low power, failure and discovery. No constant alarm.

---

## 15. Technical architecture (Godot 4)
- `GameState` (autoload): phase, roles, design, resources, log.
- `DataDB`: loads `components.json`, `sites.json`, `launchers.json`, `events.json`, `objectives.json`, `map_<site>.json` (all editable without code).
- `DesignValidator`: sums mass, cost, power and data; checks compatibility; generates warnings.
- `GridBay`: grid, drag/rotate, adjacency calculation, line drawing.
- `RoleManager`: hot-seat, permissions per role, sign-offs, conflicts.
- `SurfaceSim`: map, sol, action queue, consumption, events.
- `EventManager`: conditional triggers + resolution.
- `ReportBuilder`: score, cause chain (from the log), similar mission.
- `UI`: resource panel (component reused on every screen).

**Data pipeline:** a Python script (outside the game) cuts the site's MOLA elevation, reduces it to 12×8 and exports JSON with elevation/slope per cell. Record the product version and link.

**Export:** Godot 4.3+ Web in *single-threaded* mode (avoids requiring special headers), hosted on **itch.io** or GitHub Pages. Test in an incognito tab and on another computer.

---

## 16. MVP scope (what must be playable on Sunday at 2:30 pm)
| Item | MVP | If there is time |
|---|---|---|
| Roles | 4 hot-seat roles + sign-off | Personal objective cards |
| Objectives | 2 (A and B) | C |
| Sites | 2 (Jezero, Gale) | Meridiani |
| Power | Solar and RTG | — |
| Communications | DTE and UHF | Both |
| Windows | A and B | GMAT numbers |
| Launchers | 3 | — |
| Components | ~12 pieces | Advanced versions |
| Adjacency rules | 3 | 5 |
| Map | 1 map per site (12×8) | Navcam per terrain |
| Sols | 10 | 15 |
| Events | 4 | 5 + discovery |
| Improvisation | 2 types | 4 |
| Report | Score + 2 cause chains + similar mission + redesign | Compare attempts, design code |
| Tutorial | Contextual hint screens | CubeSat scenario |

---

## 17. Risks and responses
| Risk | Response |
|---|---|
| Big scope | MVP above; feature freeze Sat 10 pm |
| Grid with adjacency hard to code | Start with a grid without dragging (click to place) and only then dragging |
| Game doesn't run at the pitch | Web build + Windows build + 30 s video recorded Saturday night |
| Judge doesn't get it in 30 s | Anchor sentence + show adjacency and an event in the first 10 s |
| Numbers look made up | Data table with a "source/real anchor" column and the word "simplified" in the game |
| Use of data and Resources ends up decorative | Phases visibly named after CML/segments; report cites the real mission; "Learn more" link for each Resource |
