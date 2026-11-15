---
tags: [nasa-space-apps, gdd, design]
version: 1.1
date: 2026-11-14 2 pm
partially_replaces: "[[09 - GDD v1.0 (adjusted idea)]]"
---
# Adjustment v1.1 — CREWED mission, team of 2 (Pedro: art · the programmer: code · Claude: final review)

> **Reading rule:** where this note contradicts note 09, **this one wins**. The rest of 09 (CML phases, trade study, 6-resource panel, report with "why") still applies.
> The numbers are in `game/data/game-data.json` (first pass, to be tuned in playtest). Note [[10 - Game data tables]] (robotic rover) **is obsolete**.

## 1. Team decisions
| Decision | Choice |
|---|---|
| Mission type | **Crewed** (tension and emotion) |
| Team | 2 people: **Pedro = art**, **The programmer = code**, **Claude = design, data and review** |
| Hosting | **GitHub Pages** |
| Style | Pixel art, top-down + menu screens (no first-person) |

## 2. Why crewed works (and where the risk is)
- **For:** the event theme is *The Next Frontier*; the tension (bringing everyone back) is what makes the game memorable; the original designer already had this as a pillar.
- **Does it fit the challenge?** Yes. The challenge asks for objective, requirements, spacecraft, instruments, launcher, orbit/trajectory, budget, mass, power, data, communications and lifetime. The crew **adds** life support, radiation and health, without removing anything.
- **Risk 1 (scientific honesty):** no crewed mission to Mars has ever flown. The game uses **architecture concepts** (pre-positioned cargo, surface nuclear power, solar storm shelter) and must say "simplified concept", with a source. A real, citable analog: NASA's **CHAPEA** mission (4 people living a year in a simulated Mars habitat in Houston, started Oct 2025).
- **Risk 2 (tone):** avoid graphic scenes. Crew failure appears as a **sober report** ("Dr. X had to be evacuated"). The audience includes young people.
- **Risk 3 (scope):** crewed needs more art (portraits, suits). That is why the art list ([[15 - Art list (Pedro)]]) has P0/P1/P2 priorities.

## 3. Premise (for the pitch)
Fictional year 2040. A **30-sol** mission on the surface of Mars. The cargo (habitat, power, rover, supplies) is **designed by the player** and lands before the crew (pre-positioning concept). Four astronauts descend for a short stay, go on walks (EVAs) and **must be in the ascent vehicle at the fixed departure window**. The mission designer is the **Mission Director (the player)**; the crew are characters with a voice.

> **Anchor sentence:** *"You designed the mission. Now four people depend on every kilo you chose to bring."*
> Identity sentence kept: *On Mars, the biggest risk isn't what you'll find. It's discovering, too far from home, what you should have brought.*

## 4. Phases (lean for 2 people)
| # | Phase | Segment / CML | What the player does | Code cost |
|---|---|---|---|---|
| 1 | **Concept** | CML 1–2 · user | Chooses objective (A ancient life, B climate/habitability, C ice and water for humans) + stay length (8/10/12/14 sols) | low (cards) |
| 2 | **Trade study** | CML 3 · launch/space | Launcher (Heavy or Super-Heavy) × window (A nominal / B late) × power (solar or fission) × comms (relay on the orbiting ship or direct antenna) | medium (cards with effects) |
| 3 | **Cargo manifest** | CML 4 · space | **7×5** grid: build the cargo with adjacency | high (central piece) |
| 4 | **Review** | CML 4 | Automatic checklist; the crew "gives opinions" | low |
| 5 | **Landing** | space | Result screen with explained probability (no animation) | low |
| 6 | **Surface** | ground/space | Sol by sol: EVAs with the crew, events, **ascent window** | high |
| 7 | **Report** | user | Score, cause chain, similar real mission, "redesign" | medium |

**Final cuts (team of 2):** multiplayer/hot-seat (becomes a *stretch*), animated launch and cruise, multiple sites (only **1 site**, inspired by Jezero), CubeSat scenario, Navcam per terrain, compare attempts, radio interference rule.

## 5. Crew (4 fictional characters) — v0.1's "crew system" returns
Each has **Condition** (0–100), a **passive bonus** and a **voice** (short line in events). Portrait with 2 expressions (normal / worried).

| Character (fictional) | Role | Bonus | Suffers most from |
|---|---|---|---|
| **Cmdr. Vega** | Commander | In events, shows 1 extra option; −10% risk in improvisation | — |
| **Dr. Okoye** | Geologist | +25% science value of samples | Long EVA |
| **Eng. Tanaka** | Engineer | Repairs cost half the time/parts | Lack of power |
| **Dr. Duarte** | Physician | Recovers +8 Condition/sol; medical kit goes further | Radiation |

**EVA = 2 people** (4 with extra suits). Who goes out matters: geologist at a science target, engineer for a repair.
Condition < 40 → no EVA; < 15 → must return to the habitat; 0 → evacuation (end of the mission for that person; sober report).

## 6. The 6 resources + crew panel
| Resource (bar) | Here it means |
|---|---|
| **Mass** | tonnes of cargo vs. launcher capacity (minus the habitat core + lander) |
| **Power** | kWh/sol generated vs. consumed |
| **Budget** | game M$: core + launcher + items |
| **Data** | Mb generated by instruments × Mb sent per sol (communications) |
| **Communications** | Mb/sol of downlink; 4 to 24 min Mars–Earth delay (real concept) |
| **Time** | **sols of supplies** vs. planned stay + ascent window |
Side panel: **Condition of each crew member** and accumulated radiation dose.

## 7. Cargo manifest (grid) and adjacency
7×5 grid = 35 cells. The full cargo doesn't fit: everything adds up to ~31 cells, ~47 t and ~1,250 M$, against a budget of 2,000 M$ (core 500 + launcher 400 to 700) and a capacity of 27 t (Heavy) or 47 t (Super-heavy) after the core. **You have to choose.**
Items and numbers: `game/data/game-data.json`.

**3 rules in the MVP** (the 4th is a stretch):
| Rule | Condition | Effect | Real concept |
|---|---|---|---|
| 🟧 **Heat** | hot source (fission) next to a `heat_sensitive`/`clean` item (sample container, medical kit) | −50% value of samples / medicine | Thermal control |
| 🟫 **Contamination** | drill (`contaminant`) next to container (`clean`) | −50% sample value | Planetary protection and cleanliness |
| 🟦 **Shielding** | water tank next to the storm shelter | radiation dose **−50%** (shelter only: −25%; no shelter: 0%) | Water as shielding (real shelter concept) |
| ⬜ *(stretch)* Bus | high-draw item next to a battery | −losses | Cabling |

Rules appear as colored lines **before** dropping the piece.

## 8. Surface (the lean "crawler")
**10×8 map** (hand-made, in the JSON): plain/rock/sand/slope terrain + 4 science targets + lander. Clicking a target computes the **route cost** (shortest path with terrain costs) and shows: suit hours, power, risk and the Condition it will cost.

**Each sol:**
1. **Briefing:** expected power, dust state (the weather station warns 1 sol ahead), supplies, Condition.
2. **Choose EVA(s):** pair, target, transport (on foot / open rover / pressurized), up to **8 h of suit time** per EVA.
3. **Execute:** result + the sol's event (if any).
4. **Summary:** resources before → after.

**Ascent window:** fixed by the chosen stay (e.g. sol 10). **It doesn't change.** The countdown is always shown. It is the main source of tension: there is science left to collect, but the ship lifts off on sol 10.

### Events (5, all conditioned on state)
| Event | Trigger | Options (visible costs) |
|---|---|---|
| 🌪️ **Dust storm** | Window B or season; warning 1 sol ahead with met | Stay in the habitat (lose the EVA), shortened EVA, push on with risk; solar drops 70% |
| ☀️ **Solar particle event** | weighted random, always after sol 3 | Shelter (+ shielding), rush back (lose the EVA), ignore (Condition −30 for whoever is outside) |
| 🔧 **Equipment failure** | rover/suit, more likely with heavy use | Repair (parts/Eng. Tanaka), improvise, drop the equipment |
| 🩺 **Medical problem** | someone's Condition < 50 | Treat (kit + Dr. Duarte), rest (lose the EVA), carry on (risky) |
| 📡 **Missed relay pass** | only if comms are relay-only | Keep data (memory), prioritize the most valuable |
Randomness decides *when*; **what happens depends on the design** (the game shows the probability and why).

### Improvisation (pillar kept)
**Improvise** button with a visible list of what can be spent: ration supplies (−supply sol, +Condition), cannibalize spare parts, turn off an instrument, drink the shielding water (lose the shielding). Always shows the range of consequences and asks for confirmation.

## 9. Report and scoring
**Score 0–100:** Science 35 · Crew 25 (everyone back and final Condition) · Engineering 20 (margins, adjacencies) · Efficiency 20 (budget, data sent).
Badge: **Mission complete / Partial / Aborted**.
**Cause chain** (3 automatic cards, from the log). **Similar mission:** NASA architecture concept + CHAPEA (real analog) + Apollo (EVA and samples on the Moon). **Redesign and fly again** button.
Text always sober and educational, explaining **why**.

## 10. Collaboration (the challenge asks for it, but as "may consider")
- In the MVP, **collaboration is narrative**: the crew gives opinions and disagrees (negotiation cards with each one's voice).
- **Cheap stretch:** 2–4 player *hot-seat* mode where each human "adopts" 1 crew member and approves their part. It is just approval UI (~2 h). Only if there is time Sunday morning.
- Honesty: "multiplayer" is part of what the challenge calls a *strong solution*; without it we lose a bit in **Relevance**. We compensate with visible team decisions, a rich report and everything working.

## 11. What **must** work (2-person MVP)
1. Concept + trade study (cards), 2. grid with 3 rules, 3. review, 4. landing (text), 5. surface with EVA and ascent window, 6. 4 events, 7. report with cause chain, 8. everything running in the browser (GitHub Pages).
Event 5, improvisation and extras only after that.

## 12. Changes made in the code (Sat 11/14, ~6:30 pm)
- **Trade study = launcher × window.** Power (solar/fission) and comms (UHF/antenna) are **grid pieces**, as `game-data.json` already said. The screen says so.
- **Each target accepts 2 EVAs** (survey + deep sampling), each worth 50% of the target. With 4 targets that is 8 EVAs, which creates real tension with the ascent window.
- **Fatigue:** EVA Condition cost = 5 + **4 per hour** of suit time (new `eva_cost_per_hour` field in the JSON). Dr. Okoye loses ×1.5 on EVAs over 5 h.
- **Recovery:** everyone +4/sol; Dr. Duarte (if fit) gives +8 and the medical kit gives +5 **only to whoever is worst**.
- **Events roll at the start of the sol** and change the day's plan. The weather station warns of dust 1 sol ahead. Without Cmdr. Vega fit, the 3rd option disappears.
- **Hard landing** (chance shown beforehand): lose 1 cargo item and −10 Condition. The saved design comes back whole on "Redesign".
- **Scoring:** science normalizes by 120 raw points; instrument data only counts for the fraction sent to Earth.

## 13. Open-world surface + cutscenes (Sat 11/14, ~9 pm) — Pedro's request after the 1st playtest
Reason: the game was "complicated and not very dynamic". Replaces the 10×8 map with single-click sols.
- **Mandatory items:** the equipment the objective requires (`needs` in the JSON) is already on the grid, with a yellow frame, and cannot be removed.
- **32×20 map with fog**, generated with a fixed seed (2040 + attempt) so it is stable at the pitch. Terrain: plain, rock, sand, slope (slopes are impassable). The hand-made JSON map (10×8) becomes obsolete.
- **8 hidden points of interest:** 2 sediments, 2 clays, 2 ices, 1 ridge and 1 meteorite. Each accepts 2 collections.
- **Scout robot (WASD):** 45 moves per sol. It reveals the fog and the scanner **beeps faster** near a hidden target. Far from the habitat (more than 11 cells), it can **lose signal**; the crew recovers the robot by walking to its last position (real concept: teleoperation depends on a radio link).
- **Crew:** you click on the map (only on revealed terrain) and the route is marked; GO follows the route. E = collect. Suit time drops with each step (JSON hours × 0.2 per cell; rover × travel factor). An alarm sounds when the remaining time is barely enough to get back. If time runs out outside the habitat, there is an emergency rescue (−20 Condition).
- **5 walking events** (at most 2 per sol): dust devil, suit leak, sprained ankle, unexpected find (meteorite) and rover stuck in sand.
- **Hidden information:** the surface doesn't show the resource bar. **TAB** opens the crew and the numbers.
- **Final cutscene**, one per outcome: success (lift-off with a wave), objective not met, out of power, out of supplies, evacuation and mission aborted. The tone is always sober.
- Scoring: science now normalizes by 130.

## 14. Direct control (Sat 11/14, ~9:40 pm) — Pedro's 2nd playtest ("less clicking here and there")
- **Grid:** right-click removes the item; dragging the item off the grid discards it; R or the mouse wheel rotates.
- **Controller-style surface:** WASD moves the selected unit (you can hold the key) and **Q** switches between robot and crew. One click on the map sends the selected unit there.
- **The EVA starts** when the crew leaves the ship and **ends** when they come back. The GO and RETURN buttons were removed.
- **E = interact**, depending on context: collect at the target (progress bar) or end the sol at the ship. A floating hint shows the action.
- **Dust devils** move across the map each step. Touching one triggers the dust devil event (crew) or −5 battery (robot).
- **Robot with its own sprite** and motor sound; the astronauts have footstep sounds.

## 15. Installations and automatic return (Sat 11/14, ~9:30 pm) — Pedro's 3rd playtest
- **New items in the JSON:**
  - `charger`: robot charger; 2×1, 1.5 t, 50 M$, −2 kWh/sol. When the robot returns to the ship, the battery fills up, up to 2 times per sol. With an empty battery, E sends the robot back on its own using reserve power.
  - `beacon`: 2 relay beacons; 1×1, 0.5 t, 30 M$. The crew installs them with E, at least 4 cells from the ship and from another beacon. Each beacon extends the robot's signal range and reveals the surrounding area.
- **Automatic walk back** (no teleport): if the suit runs out, the crew walks back on its own with emergency oxygen (−20 Condition). END SOL with the crew outside makes them walk back and the sol ends on arrival. "Return" in an event also walks back.
- **Its own sound for each event:** wind, Geiger counter, metal, heart monitor, static, dust devil, hiss, thud, chime and spinning wheel. Also its own sounds for installing a beacon and recharging the robot.
- **Bottom bar** with drawn keys (WASD, Q, TAB, E) and what E does right now.

## 16. Sunday morning (11/15, ~9:30 am) — Pedro's 4th playtest
- **Several EVAs per sol:** each astronaut has 8 h of suit time per sol (less in a dust storm). You can come back and go out again with the remaining time, or send the other pair. On returning, the game picks the pair with the most suit time left. Reason: with one EVA per sol it was impossible to study everything and the mission always failed.
- **Map (M or MAP button):** the whole map with what has been discovered. One click marks a point (up to 6) and GO THERE takes the selected unit to the most recent mark. Marks also appear in red in the world. Mute moved to the N key.
- **Screens redone because they were confusing:**
  - **Trade study:** large cards with a title + one line.
  - **Cargo:** short names; under the grid only what is MISSING; on the right, only the item under the mouse; the "remove" button is gone.
  - **Report:** large badge, 4 bars, one main cause, real mission in one line; no resource bar.

## 17. Balancing and fixes (Sun 11/15, ~10 am)
- **Fatigue** (JSON `condition_rules`): an EVA costs 3 + 1.5 per hour (before 5 + 4); recovery of 10 per sol (before 4), +6 for whoever stayed on the ship; can't go out below 30 (before 40). Okoye loses ×1.25 on long EVAs.
- **Badges:** complete from 75, partial from 45 (before 80 and 50). Science normalizes by 90.
- **Map** redone with the game's art in miniature (8 px): terrain, ship, targets, robot, astronaut, beacons, dust devils and red flags on the marks. GO, CLEAR and CLOSE buttons.
- **Cargo:** the dragged piece keeps the point where it was picked up and, if it doesn't fit, goes back to where it was. TRASH button (throws away what is in hand), notice of the item in hand, and right-click also discards.

## 18. Economy, science goal and random map (Sun 11/15, ~10:30 am)
- **Economy** (JSON): budget of 1,800 M$ (before 2,000). Prices: reactor 300, solar panel 45, life support 140, pressurized rover 300, open rover 90, medical kit 60, charger 60. With the Heavy rocket the limit is **weight**; with the Super-Heavy the limit becomes **money**.
- **Science goal:** below **27/35** science points the mission **fails** (MISSION FAILED badge, with its own cutscene and the reason in the report). The surface shows "SCI x/27" on a bar that turns green when the goal is reached. The value is in `scoring.seals.min_science`.
- **Random map:** each mission generates a new map, with targets in different places. If any target is unreachable, the map is regenerated (up to 30 attempts). `GS.map_seed` fixes a map for the pitch, if needed.
- Automatic test (simple bot, 6 sols): 27.5 science, MISSION COMPLETE at the limit. It became demanding, but possible.

## 19. Cargo-linked events and new obstacles (Sun 11/15, ~10:50 am)
- **9 events that depend on what was brought** (`GS.CARGO_EVENTS`; at most 1 event per sol, drawn from the possible ones, with a 45% chance of being a cargo event). The pop-up shows the item's icon.
  - **Reactor overheating** (reactor): throttle to 50%, or send Tanaka to clean it, or ignore it and run a 30% risk of shutdown.
  - **Dusty panels** (solar): cleaning costs 1 h of suit time for 2 crew members; if not cleaned, −40% solar power for the day.
  - **Life support filter** (life support): spare part, or Tanaka fixes it, or −2 supply sols.
  - **Water tank leak** (water): spare part, or move the water (lose the shielding), or −2 sols.
  - **Misaligned antenna** (HGA/UHF): realigning costs 1 h of suit time for 2 crew members; otherwise no data goes out that day.
  - **Flat tire** (rover): spare part, or no rover that day, or a quick patch (more chance of failure later).
  - **Damaged supply crate** (crate): −1 supply sol.
  - **Good news, mineral signal** (spectrometer): reveals a hidden target and marks it on the map.
  - **Good news, clear sky** (solar): +50% solar power for the day.
- **New obstacles on the random map:**
  - **Boulder fields:** robot and rovers can't pass; on foot, +0.3 h per cell.
  - **Cracks:** nobody crosses.
  - Both appear on the minimap, with a notice when you bump into them. The target reachability test takes cracks into account.
- New art (AI, Claude): `map_boulder.png` and `map_crack.png`.

## 20. Difficulty levels (Sun 11/15, ~10:35 am) — chosen on the briefing screen
| | EASY | MEDIUM (default) | HARD |
|---|---|---|---|
| Lander grid | 7×5 | 6×4 | 5×4 |
| Budget | 1,800 M$ | 1,500 M$ | 1,300 M$ |
| Robot vision (radius) | 2.5 | 2.0 | 1.5 |
| Beep range | 4.5 | 3.5 | 2.5 |
| Robot moves/sol | 40 | 30 | 22 |
| Robot recharges/sol | 1 | 1 | 1 |
| Extra dust devils | 0 | +1 | +2 |
| Walking events | ×1 | ×1.3 | ×1.6 |
| Cargo event chance | 45% | 55% | 65% |
| Boulders and cracks | ×1 | ×1.3 | ×1.6 |
- The science goal stays 27/35 on all of them. Values in `GS.DIFF`. If the grid shrinks, whatever doesn't fit leaves the cargo.
- Solar panels are now stackable (up to 3), so solar power is a real alternative to the reactor on the hard modes.

## 21. The robot marks what it finds (Sun 11/15, ~10:45 am)
- Every target the robot discovers gets an **automatic flag** on the map. If it is of the objective's type, the notice says "GOAL TARGET!".
- **G:** the crew walks on its own to the nearest reachable flag that still has a sample to collect. With the robot on top of a target, E does the same.
- When the target is collected 2/2, the flag disappears on its own.

## 22. Budget per difficulty (Sun 11/15, ~10:20 am)
- The fixed cost is 900 M$ (core 500 + launcher 400). The minimum kit costs ~580–615 M$: ECLSS, 3 solar panels, UHF, suits, open rover, shelter, medical kit and the objective's equipment.
- With the old budget, medium (1500) and hard (1300) couldn't even pay for the essentials.
- **New budget:** easy 1800 (~290 left), medium **1700** (~190 left) and hard **1580** (~65–100 left).
- The test confirmed the minimum kit passes the review on all 3 levels and all 3 objectives.

## 23. "More game" package (Sun 11/15, ~11:30 am)
- **TAB:** the crew cards were redone (portrait in a window, no overlap) and the panel no longer covers the bottom bar, so MAP and END SOL work with TAB open.
- **Scarce food:**
  - The base brings 6 sols (before 12); each supply crate is worth 4 sols (before 8, max. 4 crates, 1.5 t); each water tank is worth 3 sols.
  - Consumption is 1 sol/day + 0.25 per astronaut who went on an EVA.
  - Food needed: round up of stay × 1.25 + 2 (for 10 sols, 15).
- **Goals by difficulty and length:**
  - Easy: 1 target type. Medium and hard: 2 types. +1 type if the stay is ≥ 12 sols; +1 with the EXTRA GOAL challenge (max. 4).
  - The order of types is: the objective's main one, the secondary one, then ridge, meteorite, sediment, clay and ice.
  - The mission is only complete if all goals are met; science is proportional to the goals met.
- **Adjacency combos** (bonuses; they appear on the grid with a pulsing green line, in the item info and with a flash when formed):

  | Combo | Items side by side | Effect |
  |---|---|---|
  | Water Shield | water + shelter | radiation −50% |
  | Field Lab | drill kit + sample tubes | samples +20% |
  | Power Pack | battery + solar panel | battery +50% |
  | Mineral Scan | spectrometer + drill kit | scanner range +1 |
  | Sick Bay | medical kit + shelter | +4 healing per sol |
  | Pit Crew | spare parts + rover | 60% fewer breakdowns |
  | Pantry | supplies + water | +2 food sols |
  | Relay Hub | charger + beacon | +1 beacon |
  | Weather Link | weather station + antenna | data +25% |
  | Suit Rack | extra suits + spare parts | +1 h suit time |

- **Side jobs (1 per sol)**, shown on the "SIDE JOB" strip above the science bar:
  - take the robot to the "?" → +4 science
  - find a new target → +6 robot moves
  - collect a target 2/2 → +3 science and +10 condition
  - install a beacon → +2 science and +8 moves
  - end an EVA with 2 h or more of suit time → +8 condition
- **Juice:** the screen shakes on events, finds and signal loss; colored flashes; floating texts (+SCI, GOAL!, JOB DONE); the science bar pulses; the report badge scales in; the report bars fill with animation; tokens count up to the final value.
- **Optional challenges** (UPGRADES & CHALLENGES screen, opened from the intro or the report), each with a token bonus:
  - Tight Money: −100 M$
  - Small Bay: −1 column, never below 5
  - Bad Luck: +events and +hazards
  - Hungry Crew: +0.5 food per sol
  - Weak Robot: −30% battery
  - Storm Season: double the chance of dust
  - Extra Goal: +1 goal
- **Tokens and permanent upgrades** (saved in `user://margin_save.json`):
  - Tokens per mission: (score ÷ 10 + badge + goals + jobs) × difficulty (1 / 1.5 / 2) × (1 + challenge bonus).
  - Upgrades:
    - More Funding: +50 M$ per level (3 levels)
    - Wider Bay: +1 column, up to 7
    - Lighter Core: +2 t per level
    - Better Suits: +1 h per level
    - Robot Battery: +5 moves per level
    - Dense Rations: +2 sols per level
    - Scanner+: +0.5 range per level

## 24. The science goal requires the whole stay + layout fixes (Sun 11/15, ~11:20 am)
- **Formula:** science (0–35) = raw points ÷ K × 35, with K = 165 × (stay ÷ 10) × level (easy 0.8; medium 1.0; hard 1.05). Before, K was fixed at 90.
- **Example:** on medium with 10 sols, the required 27 points equal about 127 raw points, i.e. collecting almost every target and doing the side jobs.
- **Test:** the bot on medium with 8 sols scored 19–23 science (before, 31–33).
- **Intro:** card texts shortened and lines spaced; the cards no longer overlap the difficulty and the buttons don't touch.
- **Review:** the checklist is now built with a container, so wrapped lines no longer overlap.
- **Exploration help:** text shortened, mentioning G, the side jobs and the notice "the goal needs every sol".

## 25. Upgrades and challenges in a single, discreet button (Sun 11/15, ~11:25 am)
- **Intro:** the two buttons became a single gray text link, without a box: "UPGRADES & CHALLENGES (N TOKENS) >". It opens the screen showing both columns (challenges on the left, upgrades on the right).
- **Report:** the UPGRADES button became the link "SPEND N TOKENS >", right below the tokens earned. Only two big buttons remain: REDESIGN & FLY AGAIN and TITLE.
- **FIELD LAB combo:** now sample tubes + spectrometer. Before it was drill kit + tubes, but that clashed with the contamination rule; with the change, the combo and the rule no longer contradict each other.

## 26. New token economy: 1 challenge unlocks 1 upgrade (Sun 11/15, ~12:10 pm)
- **Challenge → upgrade pairs:**

  | Challenge | Upgrade it unlocks |
  |---|---|
  | Tight Money | More Funding |
  | Small Bay | Wider Bay |
  | Bad Luck | Better Suits |
  | Hungry Crew | Dense Rations |
  | Weak Robot | Robot Battery |
  | Storm Season | Scanner+ |
  | Extra Goal | Lighter Core |

- An upgrade only unlocks when you win a mission (complete or partial) with the paired challenge turned on. Once unlocked, it still has to be bought with tokens.
- **Tokens are now scarce:**
  - Failed mission: 0.
  - Partial mission: +1. Complete mission: +3.
  - +1 per challenge turned on and +1 on hard.
- **Costs:** 2–4 tokens per level; Wider Bay costs 4.
- **New save:** `user://margin_save_v2.json`. Tokens accumulated under the old rule were discarded.
- **Screen:** the left column has the challenges, and those already won show "(WON)". The right one has the upgrades: locked ones appear in gray with "(LOCKED)". The report shows "UNLOCKED: …" when something is unlocked.
