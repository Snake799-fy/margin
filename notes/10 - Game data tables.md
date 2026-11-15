---
tags: [nasa-space-apps, data, balancing]
---
# Game data tables (v1, to become JSON)

> ⚠️ **Obsolete (robotic rover).** The data for the crewed version is in `game/data/game-data.json`. This note is kept only for the real anchors from robotic missions.

> Game numbers are **simplified and balanced for fun**; the "real anchor" column says where the idea comes from. Before publishing, whoever handles the data checks the anchors at the source and records the link in [[13 - Project page, pitch and demo]] (References). Values marked *≈* are approximate.

## Real anchors (for calibration and for the "similar mission" report)
| Mission | Rover mass (≈) | Power | Site | Highlight for the report |
|---|---|---|---|---|
| Sojourner (1997) | ≈ 11 kg | Solar | Ares Vallis | First rover; short operation |
| Spirit and Opportunity (2004) | ≈ 185 kg each | Solar | Gusev / Meridiani | Planned for ~90 sols, lasted years; Spirit got stuck in sand; Opportunity lost in the 2018 storm |
| Curiosity (2012) | ≈ 900 kg | RTG (MMRTG, ≈ 110 W at launch) | Gale | Wheels damaged on sharp terrain |
| Perseverance (2021) | ≈ 1,025 kg | RTG (MMRTG) | Jezero | Sample collection and caching |

Other anchored facts: Earth–Mars windows every ~26 months; ~7-month trip; communication delay of ~4 to ~24 min; 1 sol ≈ 24h39m; most rover data comes back through relay orbiters.

## Mission classes (budget)
| Class | Budget (game M$) | Grid | Max components |
|---|---|---|---|
| Small | 400 | 5×4 | 7 |
| Medium | 900 | 6×5 | 10 |
| Flagship | 2,000 | 7×6 | 14 |

## Launchers (generic classes)
| Class | Capacity to Mars, Window A (kg) | Window B (kg) | Cost (M$) |
|---|---|---|---|
| Light | 700 | 850 | 90 |
| Medium | 1,800 | 2,100 | 180 |
| Heavy | 4,000 | 4,600 | 350 |
Launched mass = rover mass × **3.5** (cruise stage + heat shield + descent, simplified). E.g. a 400 kg rover → 1,400 kg launched → needs the Medium.

## Sites
| Site | Latitude (≈) | Elevation | Sun factor | Science bonus | EDL risk | Map terrain |
|---|---|---|---|---|---|---|
| Jezero | 18°N | extract from MOLA | 0.85 | Objective A ×1.5 | medium | delta, rocks |
| Gale | 5°S | extract from MOLA | 1.00 | Objective B ×1.5 | low (low site) | slopes, layers |
| Meridiani | 2°S | extract from MOLA | 1.00 | C ×1.2 | low | plain, sand |

## Components (MVP, ~12)
| ID | Name | Cat. | Size | Mass kg | Cost M$ | Power | Data Mb/use | Science | Tags |
|---|---|---|---|---|---|---|---|---|---|
| rtg | RTG | Power | 2×2 | 45 | 150 | +110 W continuous | — | — | `hot` |
| solar_s | Simple solar panel | Power | 2×1 | 15 | 20 | +140 W peak × sun factor × dust | — | — | — |
| solar_a | Advanced solar panel (with cleaning) | Power | 2×1 | 22 | 45 | same +20%, −50% dust loss | — | — | — |
| bat | Battery | Battery | 1×1 | 10 | 10 | stores 600 Wh | — | — | `needs_heat` |
| cpu | On-board computer | Computer | 1×1 | 5 | 30 | −20 W | 400 Mb memory | — | `needs_heat` |
| hga | Direct antenna (high gain) | Comms | 1×2 | 12 | 40 | −40 W when transmitting | downlink 30 Mb/window | — | `emitter` |
| uhf | UHF radio (relay) | Comms | 1×1 | 4 | 15 | −15 W when transmitting | downlink 90 Mb/pass | — | `emitter` |
| heat | Heaters + insulation | Thermal | 1×1 | 6 | 8 | −30 Wh/night (−50% if next to `hot`) | — | — | — |
| cam | Mast camera | Instrument | 1×1 | 4 | 20 | −10 W | 20 | 2 | — |
| spec | Spectrometer | Instrument | 1×2 | 8 | 60 | −25 W | 35 | 5 | `sensitive` |
| chem | Chemistry lab | Instrument | 2×2 | 40 | 150 | −80 W | 60 | 8 | `sensitive` |
| met | Weather station | Instrument | 1×1 | 3 | 15 | −5 W | 5 | 2 (forecasts dust) | — |
| radar | Subsurface radar | Instrument | 1×2 | 7 | 50 | −30 W | 50 | 6 (obj. C) | `sensitive` |
| drill | Drill | Sampling | 1×1 | 15 | 40 | −60 W | 5 | — | `contaminant` |
| tubes | Sample tubes (5) | Sampling | 1×1 | 5 | 30 | — | — | 4 per sample | `clean`, `heat_sensitive` |
| spare | Redundant module | Structure | 1×1 | 8 | 25 | — | — | — | enables the "reuse" improvisation |

## Adjacency rules (orthogonal neighbors)
| Rule | If A has… and B has… | Effect |
|---|---|---|
| Useful heat | `hot` next to `needs_heat` | B uses no heater at night |
| Bad heat | `hot` next to `sensitive` or `heat_sensitive` | data/sample quality of B −30% |
| Interference | `emitter` next to `sensitive` | data quality of B −40% |
| Contamination | `contaminant` next to `clean` | value of each sample −50% |
| Bus | instrument ≥ 50 W next to `bat` | −5 W consumption |

## Daily power (simplified)
`power_sol = (sum of panels × 6 h of useful sun × sun_factor × (1 − dust)) + (RTG × 24 h)`
Dust: 0.1 normal · 0.4 storm season · 0.7 active storm (the advanced panel halves the loss).

## Daily communications
- DTE: 1 window/sol × 30 Mb (with HGA).
- UHF: 2 passes/sol × 90 Mb (10% chance of missing one; 0% if there is also an HGA as backup).

## Slope → movement
| Slope between cells (from MOLA) | Power per cell | Risk |
|---|---|---|
| flat | 40 Wh | — |
| moderate | 80 Wh | rock: 10% wheel damage |
| steep | 150 Wh | 25% damage; blocked if integrity < 50% |
| sand (marked) | 60 Wh | 30% chance of getting stuck without a prior photo |

## Scoring
See GDD §11. Science = Σ(instrument value × quality × site bonus) per target **sent to Earth** (data not sent doesn't count: this teaches that downlink is a resource).
