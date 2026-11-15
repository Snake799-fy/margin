---
tags: [nasa-space-apps, llm-council]
---
# Council verdict (LLM Council)

> ⚠️ **Update 11/14 ~1:40 pm:** the council only analyzed the guide's summary. The full official challenge text ([[07 - Official challenge text and Resources]]) showed that (1) MOLA/Mars Trek are **not** in the Resources tab and (2) the challenge asks for a complete mission design (spacecraft, launcher, orbit, budget) and a team mode of up to 4 people. The idea was restructured in [[09 - GDD v1.0 (adjusted idea)]]. What follows is still valid as a scope warning.

Format: 5 independent advisors (Contrarian, First Principles, Expansionist, Outsider, Executor), anonymous review by 2 reviewers (instead of 5, to save tokens) and a synthesis.

## Where the council agrees (high confidence)
- **Adjust, don't replace.** All 5 said so.
- **Drop first-person**: top-down 2D on a grid keeps the mechanic with much less art and code (4 of 5 asked for it).
- **Playable vertical slice** instead of the doc's scope: ~8–10 sectors, 3–4 events, ~8 items, 1 improvisation.
- **Visible, decisive NASA data**: elevation map on the planning screen, route that changes the cost, mention in the final evaluation.
- **Adjacency is the creative differentiator.** Show it in the first 10 s of the demo.
- **HTML5 build (Godot Web) with a playable link**, declare AI, register the NASA resource, no minors in the video.

## Where they disagree
- **Is a field trip a "complete mission"?** The Contrarian and the Outsider see a real Relevance risk. First Principles thinks framing alone solves it. The skeptical reviewer said framing is rhetoric and a literal judge will notice.
- **Team size.** With 4–6 people it is feasible; with 2–3 it is risky (only First Principles and the Executor touched on this).
- **Dataset ambition.** The Expansionist suggests choosing real sites (Jezero, Gale); the others ask for just one cut-out.

## Blind spots the review caught
1. Nobody checked whether the data is in the challenge's **Resources** tab (eligibility risk).
2. The "design" gap is real: a **Screen 0 for mission design** is missing.
3. Missing: built-in tutorial, playtest with a stranger, and a **plan B** (static JSON/PNG of the terrain + 30 s video in case the build fails).
4. License for art and audio packs; AI notice.

## Recommendation
**Keep the idea, in a reduced version.**
1. Screen 0 (~1 min): landing site, vehicle, duration. A simple mass/power budget sets the starting resources and the case size.
2. Field trip in top-down 2D with the real terrain on the map; the route changes the cost.
3. 5×5 case with 3 adjacency rules (heat, power, contamination).
4. 3–4 events, 1 improvisation with a visible list, 3 resources.
5. Final screen: planned vs. what happened, linked to how NASA decides.

Freeze features Saturday ~10 pm. Sunday morning is only polish, build, playtest and submission.

## First thing to do (now)
Open the challenge 13 page on spaceappschallenge.org, read the **Resources** tab and confirm which NASA data goes in. In parallel, decide on top-down 2D and how many people code.

## Condition to change the idea
If nobody on the team knows Godot (or only 1–2 people code), cut down even more (see [[06 - Decisions and open items]]). Changing the game only makes sense if Screen 0 and the NASA data don't fit in the time.
