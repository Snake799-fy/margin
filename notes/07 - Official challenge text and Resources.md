---
tags: [nasa-space-apps, challenge, official-source]
source: https://www.spaceappschallenge.org/2026/challenges/space-mission-design-game/
read_on: 2026-11-14 13:35
---
# Full official text of challenge 13 (faithful summary) and Resources tab

> Read directly on the official page during the hackathon. The Belo Horizonte participant guide only has a summary; **this is the text the global judges use.**

## Challenge (faithful summary)
Designing a space mission involves competing demands: **mission objectives, spacecraft design, science instruments, launch vehicles, budget, power, mass, communications and orbital constraints**. Students rarely experience a whole mission, **from concept to operation**. The challenge is to create an interactive game in which participants **design, manage and simulate a complete space mission**, making engineering decisions, managing limited resources and **evaluating how each choice shapes** the mission's success.

## Background (key points)
- Decisions about spacecraft, instruments, launcher, orbit, power, mass, communications, budget and **mission lifetime**.
- Example given by NASA itself: a better instrument increases science value, but also **mass, power use, data volume and cost**.
- Current tools treat topics in isolation; what is missing is showing **how the elements interact as a system**.
- Players can play alone **or in teams of up to 4 people**, each contributing to the strategy.

## Objectives (what a "strong solution" has)
1. Working game/simulation with a **clear interface**.
2. **Mission configuration system**.
3. **Resource management mechanics**.
4. **Collaboration or multiplayer for up to 4 participants**.
5. **Mission simulation and evaluation system**.
6. Performance feedback that rewards good engineering decisions, efficient resource use, **successful collaboration** and meeting the objectives.

Suggested flow: define the objective → set requirements → design the spacecraft → choose instruments → choose launcher and orbit → manage budget, mass, power, communications, data and lifetime.

## Considerations (not mandatory, but they score in Relevance)
**Game design:** accessible at several levels; solo and team (up to 4); distinct roles (planning, spacecraft design, science, communications, resources); clear objectives and feedback on **why** the mission succeeded or failed; ability to **modify the design and simulate several times**; scoring (success, science value, efficiency, decisions); difficulty levels, mission types or scenarios.

**Mission design:** start from the objective; **every relevant decision has a consequence**; show that **there is no single perfect solution**; realistic constraints (budget, mass, power, communications, lifetime).

**Spacecraft and payload:** structure, power, batteries, communications, on-board computer, attitude control, instruments. Instruments with mass, power, cost, data generated and science value. Simple or advanced components depending on difficulty.

**Orbit and launch:** several orbit options explained; effect on coverage, observation, communications and lifetime; launchers with different capacities, costs and orbits; **mass × orbit × launcher compatibility check**.

**Resources to display clearly:** **Mass, Power, Budget, Data, Communications, Time** (development and lifetime).

**Collaboration:** up to 4 people; different roles with **collective decisions**; situations where you must **negotiate priorities**; the outcome depends on coordination.

**Educational value:** simple concepts; introduce orbital altitude, payload capacity, consumption, data rate and communications **inside the game**; tutorials and visual indicators; **explain why** a decision affects performance, not just "right/wrong".

**Suggested extras:** multiple scenarios; random events; difficulty levels; interactive spacecraft visualization; real-time resource panel; leaderboard; **mission report at the end**; save/share/compare designs; co-op mode; competitive mode; sandbox; **post-mission analysis explaining success or failure**.

## Resources tab (official list: use at least 1, centrally)
| Resource | Link | How we use it in the game |
|---|---|---|
| Design and Develop Science Missions | https://www.nasa.gov/wp-content/uploads/2025/04/250323-design-and-develop-science-mission.pdf | The **4 segments** (launch, space, ground, user) become the structure of screens and roles |
| GMAT (General Mission Analysis Tool) | https://software.nasa.gov/software/GSC-19468-1 | *Optional/stretch:* compute the 2 launch windows (travel time) and tabulate them in the game |
| Concept Maturity Levels (JPL) | https://dataverse.jpl.nasa.gov/dataset.xhtml?persistentId=hdl:2014/44299 | The game phases follow **CML 1→4** (idea → feasibility → trade study → point design) |
| Mission Design Lab (GSFC) | https://etd.gsfc.nasa.gov/capabilities/integrated-design-center/mission-design-lab/ | The list of **disciplines** (power, propulsion, thermal, structure, avionics, communications, attitude, cost, risk) becomes the component categories; "trade study" gets its own screen |
| NASA Mission Viz | https://nasa.github.io/mission-viz/ | Visual reference for the cruise screen (trajectory) and a "see the real thing" link |
| A Learning Game About Telescopes (Webb) | https://science.nasa.gov/mission/webb/game-build-it-yourself/ | Direct inspiration: the objective constrains instruments; at the end, **compare with similar real missions** |
| CubeSat 101 | https://www3.nasa.gov/sites/default/files/atoms/files/nasa_csli_cubesat_101_508.pdf | "CubeSat" tutorial scenario (ConOps → launch → operation) |
| Visualize a Space Mission Using VR (2023) | https://www.spaceappschallenge.org/2023/challenges/visualize-a-space-mission-using-virtual-reality/ | Reference for a "complete mission": concept, trajectory, timeline |
| CSA Digital Games and Activities | https://www.asc-csa.gc.ca/eng/youth-educators/digital-games-and-activities.asp | Reference for educational tone (partner agency) |

## Consequences for our idea
1. **MOLA/Mars Trek are NOT in the Resources tab.** They can be used as **extra data**, but the project must centrally use at least one resource from the list above.
2. The challenge is about **mission design (from concept to operation)**, not surface survival. The field trip becomes **only the operations phase**.
3. **Team mode with roles** is asked for several times: the "crew" of the original doc should become **the players**.
4. The panel must show **six resources**: Mass, Power, Budget, Data, Communications and Time.
5. There must be a **post-mission report and analysis** and a **"redesign and fly again"** option.
