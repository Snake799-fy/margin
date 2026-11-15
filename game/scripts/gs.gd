extends Node
## GS = Game State (autoload). Holds the data from game-data.json, the player's
## design (choices + cargo grid) and the mission state on the surface.
## All game rules live here so the screens only draw and call functions.

const DATA_PATH := "res://data/game-data.json"

var D: Dictionary = {}          # raw data from JSON
var comp := {}                  # component id -> dict

# ---------------- difficulty ----------------
const DIFF := {
	"easy":   {"cols": 7, "rows": 5, "budget": 1800, "reveal": 2.5, "scan": 4.5, "moves": 40, "recharges": 1, "hazards": 0, "walk": 1.0, "cargo_p": 0.45, "obstacles": 1.0},
	"medium": {"cols": 6, "rows": 4, "budget": 1700, "reveal": 2.0, "scan": 3.5, "moves": 30, "recharges": 1, "hazards": 1, "walk": 1.3, "cargo_p": 0.55, "obstacles": 1.3},
	"hard":   {"cols": 5, "rows": 4, "budget": 1580, "reveal": 1.5, "scan": 2.5, "moves": 22, "recharges": 1, "hazards": 2, "walk": 1.6, "cargo_p": 0.65, "obstacles": 1.6},
}
var difficulty := "medium"

func dv(key: String):
	var v = DIFF[difficulty][key]
	match key:
		"budget": v += 50 * up("funding") - (100 if mod("broke") else 0)
		"cols": v = maxi(mini(5, v), mini(7, v + up("bay")) - (1 if mod("cramped") else 0))
		"moves": v = int((v + 5 * up("robot")) * (0.7 if mod("weakbot") else 1.0))
		"cargo_p": v += 0.25 if mod("badluck") else 0.0
		"hazards": v += 1 if mod("badluck") else 0
		"scan": v += 0.5 * up("scanner") + (1.0 if combo("mineral") else 0.0)
	return v

# ---------------- goals: more of them on harder levels and longer stays ----------------
const GOAL_BASE := {"easy": 1, "medium": 2, "hard": 2}
func goal_types() -> Array:
	var o := objective_data()
	var n: int = GOAL_BASE[difficulty] + (1 if stay >= 12 else 0) + (1 if mod("overachiever") else 0)
	var out: Array = []
	for t in o["target_types"] + o["secondary"] + ["ridge", "meteorite", "sediment", "clay", "ice"]:
		if not t in out: out.append(t)
	return out.slice(0, mini(n, 4))

func goals_done() -> Array:
	var done: Array = []
	for t in pois:
		if visited.has(t["id"]) and t["type"] in goal_types() and not t["type"] in done: done.append(t["type"])
	return done

## Food: 1 sol each sol, plus a bit for every astronaut who went outside (EVAs are hungry work).
func food_need() -> int:
	return int(ceil(stay * (1.75 + (0.5 if mod("hungry") else 0.0)))) + int(D["supply_reserve_sols"])

# ---------------- combos: items that work better side by side ----------------
const COMBOS := {
	"shield":   {"a": "water", "b": ["shelter"], "name": "WATER SHIELD", "text": "Radiation -50%"},
	"lab":      {"a": "sample_containers", "b": ["spectrometer"], "name": "FIELD LAB", "text": "Samples +20%"},
	"pack":     {"a": "battery", "b": ["solar"], "name": "POWER PACK", "text": "Battery +50%"},
	"mineral":  {"a": "spectrometer", "b": ["field_kit"], "name": "MINERAL SCAN", "text": "Scan range +1"},
	"sickbay":  {"a": "medkit", "b": ["shelter"], "name": "SICK BAY", "text": "Heal +4/sol"},
	"pitcrew":  {"a": "spares", "b": ["rover_open", "rover_pressurized"], "name": "PIT CREW", "text": "Rover safer"},
	"pantry":   {"a": "crate", "b": ["water"], "name": "PANTRY", "text": "Food +2 sols"},
	"relayhub": {"a": "charger", "b": ["beacon"], "name": "RELAY HUB", "text": "+1 beacon"},
	"weather":  {"a": "met", "b": ["hga", "uhf"], "name": "WEATHER LINK", "text": "Data +25%"},
	"suitrack": {"a": "suits", "b": ["spares"], "name": "SUIT RACK", "text": "Suit +1h"},
}
func combo_pairs(list: Array = placements) -> Array:
	var out: Array = []
	var seen := {}
	for i in list.size():
		for k in COMBOS:
			if list[i]["id"] != COMBOS[k]["a"] or seen.has(k): continue
			for j in list.size():
				if i != j and list[j]["id"] in COMBOS[k]["b"] and are_adjacent(list[i], list[j]):
					out.append([i, j, k]); seen[k] = true
					break
	return out

func combos(list: Array = placements) -> Array:
	var out: Array = []
	for c in combo_pairs(list): out.append(c[2])
	return out

func combo(k: String) -> bool:
	return k in combos()

## Combos an item can take part in (for the cargo info box).
func combos_of(id: String) -> Array:
	var out: Array = []
	for k in COMBOS:
		if COMBOS[k]["a"] == id or id in COMBOS[k]["b"]: out.append(k)
	return out

# ---------------- challenges (opt-in, more tokens) and permanent upgrades ----------------
const MODS := {
	"broke":        {"name": "TIGHT MONEY", "text": "-100 M$ budget.", "unlocks": "funding"},
	"cramped":      {"name": "SMALL BAY", "text": "Lander grid loses a column (never below 5).", "unlocks": "bay"},
	"badluck":      {"name": "BAD LUCK", "text": "More events and hazards each sol.", "unlocks": "suits"},
	"hungry":       {"name": "HUNGRY CREW", "text": "Food runs out faster.", "unlocks": "rations"},
	"weakbot":      {"name": "WEAK ROBOT", "text": "Robot battery -30%.", "unlocks": "robot"},
	"storms":       {"name": "STORM SEASON", "text": "Dust storms twice as likely.", "unlocks": "scanner"},
	"overachiever": {"name": "EXTRA GOAL", "text": "One more target type to sample.", "unlocks": "lite"},
}
## Upgrades are locked until you WIN a mission with the matching challenge on; then they cost tokens.
const UPGRADES := {
	"funding": {"name": "MORE FUNDING", "text": "+50 M$ budget per level.", "cost": [2, 3, 4]},
	"bay":     {"name": "WIDER BAY", "text": "+1 column in the lander grid.", "cost": [4]},
	"lite":    {"name": "LIGHTER CORE", "text": "+2 t launcher margin per level.", "cost": [2, 3]},
	"suits":   {"name": "BETTER SUITS", "text": "+1 h suit time per level.", "cost": [2, 3]},
	"robot":   {"name": "ROBOT BATTERY", "text": "+5 robot moves per level.", "cost": [2, 3]},
	"rations": {"name": "DENSE RATIONS", "text": "+2 sols of food per level.", "cost": [2, 3]},
	"scanner": {"name": "SCANNER+", "text": "+0.5 scanner range per level.", "cost": [2, 3]},
}
const SAVE_PATH := "user://margin_save_v2.json"   # v2: new token economy (old saves ignored)
var mods := {}
var meta := {"tokens": 0, "up": {}, "runs": 0, "best": 0, "beaten": []}
var last_unlocks: Array = []
var last_tokens := 0
var tokens_given := false
var prep_back := "intro"

func mod(id: String) -> bool: return mods.get(id, false)
func up(id: String) -> int: return int(meta["up"].get(id, 0))

func mods_on() -> int:
	var n := 0
	for k in mods:
		if mods[k]: n += 1
	return n

func challenge_for(upgrade: String) -> String:
	for k in MODS:
		if MODS[k]["unlocks"] == upgrade: return k
	return ""

func unlocked(upgrade: String) -> bool:
	return challenge_for(upgrade) in meta.get("beaten", [])

func load_meta() -> void:
	if not FileAccess.file_exists(SAVE_PATH): return
	var d = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if d is Dictionary:
		for k in d: meta[k] = d[k]

func save_meta() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f: f.store_string(JSON.stringify(meta))

func buy(id: String) -> bool:
	var lvl := up(id)
	var costs: Array = UPGRADES[id]["cost"]
	if not unlocked(id) or lvl >= costs.size() or int(meta["tokens"]) < int(costs[lvl]): return false
	meta["tokens"] = int(meta["tokens"]) - int(costs[lvl])
	meta["up"][id] = lvl + 1
	save_meta()
	return true

## Tokens are scarce: only a won mission pays (complete 3, partial 1), +1 per challenge on, +1 on hard.
## Winning with a challenge on unlocks its upgrade (it still has to be bought with tokens).
func award_tokens(rep: Dictionary) -> int:
	var won: bool = rep["seal"] in ["MISSION COMPLETE", "PARTIAL SUCCESS"]
	var t := 0
	last_unlocks = []
	if won:
		t = (3 if rep["seal"] == "MISSION COMPLETE" else 1) + mods_on() + (1 if difficulty == "hard" else 0)
		if not meta.has("beaten"): meta["beaten"] = []
		for k in mods:
			if mods[k] and not k in meta["beaten"]:
				meta["beaten"].append(k)
				last_unlocks.append(UPGRADES[MODS[k]["unlocks"]]["name"])
	last_tokens = t
	meta["tokens"] = int(meta["tokens"]) + t
	meta["runs"] = int(meta["runs"]) + 1
	meta["best"] = maxi(int(meta["best"]), int(rep["total"]))
	save_meta()
	return t

func grid_cols() -> int: return int(dv("cols"))
func grid_rows() -> int: return int(dv("rows"))
func robot_moves() -> int: return int(dv("moves"))

## Drops cargo that no longer fits after the grid shrinks (harder difficulty).
func prune_grid() -> void:
	for i in range(placements.size() - 1, -1, -1):
		var p = placements[i]
		if p["x"] + p["w"] > grid_cols() or p["y"] + p["h"] > grid_rows():
			placements.remove_at(i)

# ---------------- design (phases 1-4) ----------------
var objective := "A"
var stay := 10
var launcher := "heavy"
var window := "A"
var placements: Array = []      # [{id, x, y, w, h}]
var attempt := 1
var saved_design: Array = []    # copy of the cargo before landing damage

# ---------------- mission (phases 5-7) ----------------
var crew: Array = []            # [{id,name,role,cond,dose,evac,eva_today}]
var sol := 1
var supplies := 0.0
var battery := 0.0
var data_buffer := 0.0
var data_gen := 0.0
var data_sent := 0.0
var sample_points := 0.0
var instrument_points := 0.0
var visited := {}               # target id -> number of EVAs done there
const VISITS_PER_TARGET := 2    # each target: survey + deep sampling (50% of value each)
var vehicles_broken := {}       # vehicle id -> true
var vehicle_uses := 0
var vehicle_fragile := 0.0      # extra failure chance after improvised fixes
var spares_left := 0
var spe_happened := false
var dust_tomorrow := false
var dust_today := false
var events_seen: Array = []
var landing_ok := true
var mission_log: Array = []     # [{sol, text, cause}]
var mission_over := false
var today := {}                 # per-sol modifiers set by events
var micro_done := 0             # side jobs completed this mission


var snd: Node                   # music + sound effects (scripts/audio.gd)

func _ready() -> void:
	randomize()
	snd = preload("res://scripts/audio.gd").new()
	add_child(snd)
	var txt := FileAccess.get_file_as_string(DATA_PATH)
	D = JSON.parse_string(txt)
	for c in D["components"]:
		comp[c["id"]] = c
	stay = 10
	load_meta()


# ============================================================
# DESIGN
# ============================================================
func launcher_data() -> Dictionary:
	for l in D["launchers"]:
		if l["id"] == launcher: return l
	return D["launchers"][0]

func window_data() -> Dictionary:
	for w in D["windows"]:
		if w["id"] == window: return w
	return D["windows"][0]

func objective_data(id := "") -> Dictionary:
	if id == "": id = objective
	for o in D["objectives"]:
		if o["id"] == id: return o
	return D["objectives"][0]

const SHORT := {
	"fsp": "Reactor", "solar": "Solar panel", "battery": "Battery", "eclss": "Life suppt",
	"water": "Water tank", "crate": "Supplies", "shelter": "Shelter",
	"rover_pressurized": "Big rover", "rover_open": "Rover", "suits": "Extra suits",
	"field_kit": "Drill kit", "sample_containers": "Sample tube", "spectrometer": "Spectromtr",
	"gpr": "Radar", "met": "Weather stn", "medkit": "Medkit", "hga": "Big antenna",
	"uhf": "UHF radio", "spares": "Spare parts", "charger": "Charger", "beacon": "Beacons",
}

func short_name(id: String) -> String:
	return SHORT.get(id, id)

func count_of(id: String) -> int:
	var n := 0
	for p in placements:
		if p["id"] == id: n += 1
	return n

func has(id: String) -> bool:
	return count_of(id) > 0

func max_count(id: String) -> int:
	return int(comp[id].get("stackable", 1))

func cells_of(p: Dictionary) -> Array:
	var out := []
	for x in range(p["x"], p["x"] + p["w"]):
		for y in range(p["y"], p["y"] + p["h"]):
			out.append(Vector2i(x, y))
	return out

func cell_owner(cell: Vector2i, list: Array = placements) -> int:
	for i in list.size():
		if cell in cells_of(list[i]): return i
	return -1

func can_place(id: String, x: int, y: int, w: int, h: int, list: Array = placements) -> bool:
	if x < 0 or y < 0 or x + w > grid_cols() or y + h > grid_rows(): return false
	for cx in range(x, x + w):
		for cy in range(y, y + h):
			if cell_owner(Vector2i(cx, cy), list) != -1: return false
	return true

func are_adjacent(a: Dictionary, b: Dictionary) -> bool:
	var cb := cells_of(b)
	for c in cells_of(a):
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			if (c + d) in cb: return true
	return false

## Objective gear is mandatory: it is pre-loaded and locked in the grid.
func required_ids() -> Array:
	return objective_data()["needs"]

func ensure_required() -> void:
	var req := required_ids()
	# unlock/remove locked items that the current objective no longer needs
	for i in range(placements.size() - 1, -1, -1):
		var p = placements[i]
		if p.get("locked", false) and not p["id"] in req:
			placements.remove_at(i)
	for id in req:
		var found := false
		for p in placements:
			if p["id"] == id:
				p["locked"] = true
				found = true
		if found: continue
		var c = comp[id]
		var spot := _free_spot(id, int(c["w"]), int(c["h"]))
		if spot.x < 0: continue
		placements.append({"id": id, "x": spot.x, "y": spot.y, "w": c["w"], "h": c["h"], "rot": false, "locked": true})

func _free_spot(id: String, w: int, h: int) -> Vector2i:
	# bottom rows first, from the right, and never next to something it hates
	for y in range(grid_rows() - h, -1, -1):
		for x in range(grid_cols() - w, -1, -1):
			if not can_place(id, x, y, w, h): continue
			var test := placements.duplicate()
			test.append({"id": id, "x": x, "y": y, "w": w, "h": h})
			var bad := false
			for a in adjacency(test):
				if a["rule"] != "shielding" and (a["a"] == test.size() - 1 or a["b"] == test.size() - 1): bad = true
			if not bad: return Vector2i(x, y)
	return Vector2i(-1, -1)

func is_locked(i: int) -> bool:
	return i >= 0 and i < placements.size() and placements[i].get("locked", false)

func tags(id: String) -> Array:
	return comp[id].get("tags", [])

## Returns [{rule, a, b}] with indexes into list. rule = heat | contamination | shielding
func adjacency(list: Array = placements) -> Array:
	var out := []
	for i in list.size():
		for j in range(i + 1, list.size()):
			var a = list[i]; var b = list[j]
			if not are_adjacent(a, b): continue
			for pair in [[i, j], [j, i]]:
				var ta := tags(list[pair[0]]["id"])
				var tb := tags(list[pair[1]]["id"])
				if "hot" in ta and ("heat_sensitive" in tb or "clean" in tb):
					out.append({"rule": "heat", "a": pair[0], "b": pair[1]})
				if "contaminant" in ta and "clean" in tb:
					out.append({"rule": "contamination", "a": pair[0], "b": pair[1]})
				if "water" in ta and "shelter" in tb:
					out.append({"rule": "shielding", "a": pair[0], "b": pair[1]})
	return out

func rule_text(rule: String) -> String:
	for r in D["adjacency_rules"]:
		if r["id"] == rule: return r.get("text", "")
	return ""

## All design numbers in one place (used by HUD, review, landing and surface).
func stats(list: Array = placements) -> Dictionary:
	var core = D["core"]
	var s := {}
	var mass := 0.0
	var cost := float(core["cost"]) + float(launcher_data()["cost"])
	var energy := float(core["energy_kwh_sol"])
	var solar := 0.0
	var storage := 0.0
	var supply := float(core["base_supply_sols"])
	var supply_mult := 1.0
	var downlink := 0.0
	var counts := {}
	for p in list:
		var c = comp[p["id"]]
		counts[p["id"]] = counts.get(p["id"], 0) + 1
		mass += float(c["mass_t"])
		cost += float(c["cost"])
		var e := float(c.get("energy_kwh_sol", 0.0)) + float(c.get("energy_per_sol_kwh", 0.0))
		if p["id"] == "solar": solar += e
		else: energy += e
		storage += float(c.get("storage_kwh", 0.0))
		supply += float(c.get("supply_sols", 0.0))
		supply_mult = max(supply_mult, float(c.get("supply_multiplier", 1.0)))
		downlink += float(c.get("downlink_mb_sol", 0.0))
	supply = float(core["base_supply_sols"]) * supply_mult + (supply - float(core["base_supply_sols"]))
	supply += 2.0 * up("rations")
	var cmb := combos(list)
	if "pantry" in cmb: supply += 2.0
	if "pack" in cmb: storage *= 1.5
	if "weather" in cmb: downlink *= 1.25
	var cap := float(launcher_data()["capacity_t"]) + float(window_data()["launcher_bonus_t"]) - float(core["mass_t"]) + 2.0 * up("lite")
	s["mass"] = mass
	s["cap"] = cap
	s["mass_margin_pct"] = 100.0 * (cap - mass) / max(cap, 0.001)
	s["cost"] = cost
	s["budget"] = float(dv("budget"))
	s["energy_base"] = energy          # without solar
	s["solar"] = solar
	s["energy"] = energy + solar       # net kWh/sol on a clear day
	s["storage"] = storage
	s["supply"] = supply
	s["downlink"] = downlink
	s["counts"] = counts
	# adjacency effects
	var adj := adjacency(list)
	var sample_mult := 1.0
	var med_mult := 1.0
	var shield := false
	for a in adj:
		var bid = list[a["b"]]["id"]
		if a["rule"] == "heat":
			if bid == "medkit": med_mult = 0.5
			else: sample_mult *= 0.5
		elif a["rule"] == "contamination":
			sample_mult *= 0.5
		elif a["rule"] == "shielding":
			shield = true
	s["adj"] = adj
	s["combos"] = cmb
	if "lab" in cmb: sample_mult *= 1.2
	s["sample_mult"] = max(sample_mult, 0.25)
	s["med_mult"] = med_mult
	if shield and not shield_lost: s["rad_mult"] = 0.5
	elif counts.has("shelter"): s["rad_mult"] = 0.75
	else: s["rad_mult"] = 1.0
	return s

## Review checklist: [{ok:bool, block:bool, text}]
func review() -> Array:
	var s := stats()
	var out := []
	out.append({"ok": s["mass"] <= s["cap"], "block": true,
		"text": "Mass %.1f / %.1f t" % [s["mass"], s["cap"]] + ("" if s["mass"] <= s["cap"] else " - the launcher cannot lift it")})
	out.append({"ok": s["cost"] <= s["budget"], "block": true,
		"text": "Cost %d / %d M$" % [s["cost"], s["budget"]] + ("" if s["cost"] <= s["budget"] else " - over budget")})
	out.append({"ok": s["energy"] >= 0, "block": false,
		"text": "Power %+.0f kWh/sol" % s["energy"] + ("" if s["energy"] >= 0 else " - the habitat will run short")})
	var need := food_need()
	out.append({"ok": s["supply"] >= need, "block": false,
		"text": "Supplies %.0f sols (need %d)" % [s["supply"], need]})
	out.append({"ok": s["downlink"] > 0, "block": false,
		"text": "Downlink %.0f Mb/sol" % s["downlink"] + ("" if s["downlink"] > 0 else " - no radio, no data home")})
	var o := objective_data()
	var missing := []
	for n in o["needs"]:
		if not has(n): missing.append(comp[n]["name"])
	out.append({"ok": missing.is_empty(), "block": false,
		"text": "Objective %s gear" % o["id"] + ("" if missing.is_empty() else ": missing " + ", ".join(missing))})
	out.append({"ok": has("shelter"), "block": false,
		"text": "Storm shelter" + ("" if has("shelter") else ": none - solar storms hit hard")})
	for a in s["adj"]:
		if a["rule"] != "shielding":
			out.append({"ok": false, "block": false,
				"text": "%s next to %s: %s" % [comp[placements[a["a"]]["id"]]["name"], comp[placements[a["b"]]["id"]]["name"], rule_text(a["rule"])]})
	return out

func can_launch() -> bool:
	for r in review():
		if r["block"] and not r["ok"]: return false
	return true

## One short line from each crew member about the design.
func crew_opinions() -> Dictionary:
	var s := stats()
	var o := {}
	o["vega"] = "Mass margin %d%%. %s" % [int(s["mass_margin_pct"]), "Good." if s["mass_margin_pct"] >= 10 else "Too thin for my taste."]
	var miss := false
	for n in objective_data()["needs"]:
		if not has(n): miss = true
	o["okoye"] = "We lack the tools for the objective." if miss else ("Samples will be damaged by the layout." if s["sample_mult"] < 1.0 else "Science kit looks right.")
	o["tanaka"] = "Power is negative. We'll freeze." if s["energy"] < 0 else ("Solar only? Pray for clear skies." if not has("fsp") else "Reactor gives us margin.")
	o["duarte"] = "No shelter. Radiation is my worry." if not has("shelter") else ("Water around the shelter. Smart." if s["rad_mult"] <= 0.5 else "Shelter OK. Water next to it helps more.")
	return o


# ============================================================
# MISSION
# ============================================================
func start_mission() -> void:
	saved_design = placements.duplicate(true)
	var s := stats()
	crew.clear()
	for c in D["crew"]:
		crew.append({"id": c["id"], "name": c["name"], "role": c["role"], "cond": 100.0, "dose": 0.0, "evac": false})
	sol = 1
	supplies = s["supply"]
	battery = s["storage"]
	data_buffer = 0.0
	data_gen = 0.0
	data_sent = 0.0
	sample_points = 0.0
	instrument_points = 0.0
	visited.clear()
	vehicles_broken.clear()
	vehicle_uses = 0
	vehicle_fragile = 0.0
	spares_left = count_of("spares") * 2
	spe_happened = false
	dust_tomorrow = false
	dust_today = false
	events_seen.clear()
	mission_log.clear()
	mission_over = false
	today = {}
	micro_done = 0
	tokens_given = false
	gen_world()

func log_add(text: String, cause := false) -> void:
	mission_log.append({"sol": sol, "text": text, "cause": cause})

func member(id: String) -> Dictionary:
	for c in crew:
		if c["id"] == id: return c
	return {}

func fit(id: String) -> bool:
	var m := member(id)
	return not m.is_empty() and not m["evac"] and m["cond"] >= float(D["condition_rules"]["must_return_below"])

func can_eva(id: String) -> bool:
	var m := member(id)
	return not m.is_empty() and not m["evac"] and m["cond"] >= float(D["condition_rules"]["no_eva_below"]) \
		and not today.get("no_eva_" + id, false)

func max_team() -> int:
	return 2 + 2 * min(count_of("suits"), 1)

func landing_chance() -> Dictionary:
	var s := stats()
	var base := float(D["landing"]["base_success"])
	var pen := 0.0
	if s["mass_margin_pct"] < 10.0:
		pen = (10.0 - s["mass_margin_pct"]) * float(D["landing"]["penalty_per_missing_margin_pct"])
	return {"base": base, "penalty": pen, "p": clamp(base - pen, 0.3, 0.99)}

func roll_landing() -> bool:
	var p = landing_chance()["p"]
	landing_ok = randf() < p
	if not landing_ok:
		# hard landing: one random item is damaged, crew shaken
		var candidates := []
		for i in placements.size():
			if placements[i]["id"] != "fsp": candidates.append(i)
		if not candidates.is_empty():
			var idx = candidates.pick_random()
			var lost = comp[placements[idx]["id"]]["name"]
			placements.remove_at(idx)
			log_add("Hard landing: %s was damaged and lost." % lost, true)
		for c in crew: c["cond"] -= 10.0
	else:
		log_add("Landing on target. All cargo intact.")
	return landing_ok

# ---------------- open world (surface) ----------------
const WORLD_W := 32
const WORLD_H := 20
const RELAY_RANGE := 11.0        # beyond this, the robot can lose its signal
const POI_DEFS := [
	["sediment", "Delta sediments", 10], ["sediment", "Lakebed layers", 10],
	["clay", "Clay outcrop", 10], ["clay", "Clay vein", 10],
	["ice", "Buried ice candidate", 12], ["ice", "Ice-rich crater rim", 12],
	["ridge", "Wind-carved ridge", 6], ["meteorite", "Iron meteorite", 8],
]
var world: Array = []            # rows of terrain chars (P R S H L)
var pois: Array = []             # [{id,label,type,science,pos}]
var revealed := {}               # Vector2i -> true
var lander := Vector2i(9, 10)
var scout := {}                  # {pos, lost, moves}
var eva := {}                    # active EVA: {team, vehicle, pos, used, cap, slow, energy, found}
var beacons: Array = []          # deployed relay beacons (cells)
var marks: Array = []            # map marks set by the player (cells)
var shield_lost := false         # water moved away from the shelter (tank leak event)
var obstacles := {}              # cell -> "boulder" (blocks robot and rovers) | "crack" (blocks everyone)
var beacons_left := 0
var recharges_left := 0          # robot docking recharges left today (needs the charger)

var map_seed := 0              # 0 = new random map every mission (set a number to repeat one)

## Generates a new map until every target can be reached on the ground from the lander.
func gen_world() -> void:
	for tries in 30:
		_gen_world_once()
		if _all_reachable(): return
		map_seed = 0

func _all_reachable() -> bool:
	var seen := {lander: true}
	var q := [lander]
	while not q.is_empty():
		var c: Vector2i = q.pop_back()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var n: Vector2i = c + d
			if seen.has(n) or crew_blocked(n): continue
			seen[n] = true
			q.append(n)
	for p in pois:
		if not seen.has(p["pos"]): return false
	return pois.size() == POI_DEFS.size()

func _gen_world_once() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = map_seed if map_seed != 0 else randi()
	var n1 := FastNoiseLite.new(); n1.seed = rng.randi(); n1.frequency = 0.09
	var n2 := FastNoiseLite.new(); n2.seed = rng.randi(); n2.frequency = 0.16
	world.clear()
	for y in WORLD_H:
		var row := ""
		for x in WORLD_W:
			var v := n1.get_noise_2d(x, y)
			var s := n2.get_noise_2d(x, y)
			var ch := "P"
			if v > 0.36: ch = "H"
			elif v > 0.16: ch = "R"
			elif s < -0.28: ch = "S"
			if Vector2(x, y).distance_to(Vector2(lander)) < 2.6: ch = "P"
			if x == 0 or y == 0 or x == WORLD_W - 1 or y == WORLD_H - 1: ch = "H"
			row += ch
		world.append(row)
	_set_tile(lander, "L")
	pois.clear()
	var i := 0
	for d in POI_DEFS:
		for tries in 400:
			var c := Vector2i(rng.randi_range(2, WORLD_W - 3), rng.randi_range(2, WORLD_H - 3))
			var dist := Vector2(c).distance_to(Vector2(lander))
			if dist < 5.0 or dist > 19.0 or tile(c) == "H": continue
			var near := false
			for p in pois:
				if Vector2(c).distance_to(Vector2(p["pos"])) < 4.0: near = true
			if near: continue
			pois.append({"id": "p%d" % i, "type": d[0], "label": d[1], "science": d[2], "pos": c})
			_set_tile(c, "T")
			break
		i += 1
	_gen_obstacles(rng)
	revealed.clear()
	reveal(lander, 3.0)
	scout = {"pos": lander + Vector2i(1, 0), "lost": false, "moves": robot_moves()}
	eva = {}
	beacons.clear()
	marks.clear()
	shield_lost = false
	beacons_left = count_of("beacon") * int(comp["beacon"].get("beacons", 2)) if comp.has("beacon") else 0
	if combo("relayhub"): beacons_left += 1
	recharges_left = 0

# ---- roaming dust devils (visible hazards that move whenever you move) ----
var hazards: Array = []

func spawn_hazards() -> void:
	hazards.clear()
	var n := 2 + (2 if dust_today else 0) + (1 if sol > stay / 2 else 0) + int(dv("hazards"))
	for i in n:
		for tries in 100:
			var c := Vector2i(randi_range(2, WORLD_W - 3), randi_range(2, WORLD_H - 3))
			var d := Vector2(c).distance_to(Vector2(lander))
			if d >= 5.0 and d <= 16.0 and tile(c) != "H" and not c in hazards:
				hazards.append(c)
				break

func move_hazards() -> void:
	for i in hazards.size():
		if randf() < 0.45:
			var d: Vector2i = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)].pick_random()
			var to: Vector2i = hazards[i] + d
			if tile(to) != "H" and to != lander and Vector2(to).distance_to(Vector2(lander)) > 2.5:
				hazards[i] = to

func hazard_near(c: Vector2i) -> bool:
	for h in hazards:
		if h == c: return true
	return false

func make_walk_event(id: String) -> Dictionary:
	var e: Dictionary = WALK_EVENTS[id].duplicate(true)
	e["id"] = id
	return e

## Robot route (it can drive into the fog; slopes block it).
func robot_path(to: Vector2i) -> Array:
	var a := AStarGrid2D.new()
	a.region = Rect2i(0, 0, WORLD_W, WORLD_H)
	a.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a.update()
	for y in WORLD_H:
		for x in WORLD_W:
			if robot_blocked(Vector2i(x, y)): a.set_point_solid(Vector2i(x, y), true)
	if a.is_point_solid(to): return []
	return a.get_id_path(scout["pos"], to)

## Boulder fields (robot and rovers must go around; on foot it is slow) and cracks (nobody crosses).
func _gen_obstacles(rng: RandomNumberGenerator) -> void:
	obstacles.clear()
	var free := func(c: Vector2i) -> bool:
		return tile(c) in ["P", "R", "S"] and Vector2(c).distance_to(Vector2(lander)) > 3.0 and poi_at(c).is_empty()
	for i in int(rng.randi_range(5, 8) * float(dv("obstacles"))):
		var c := Vector2i(rng.randi_range(2, WORLD_W - 3), rng.randi_range(2, WORLD_H - 3))
		for k in rng.randi_range(2, 4):
			var b := c + Vector2i(rng.randi_range(-1, 1), rng.randi_range(-1, 1))
			if free.call(b): obstacles[b] = "boulder"
	for i in int(rng.randi_range(2, 3) * float(dv("obstacles"))):
		var c := Vector2i(rng.randi_range(3, WORLD_W - 4), rng.randi_range(3, WORLD_H - 4))
		var horiz := rng.randf() < 0.5
		for k in rng.randi_range(3, 5):
			var b := c + (Vector2i(k, 0) if horiz else Vector2i(0, k))
			if free.call(b): obstacles[b] = "crack"

func obstacle(c: Vector2i) -> String:
	return obstacles.get(c, "")

## Can the crew step here? (vehicle "" = on foot)
func crew_blocked(c: Vector2i, veh := "") -> bool:
	if tile(c) == "H" or obstacle(c) == "crack": return true
	return veh != "" and obstacle(c) == "boulder"

func robot_blocked(c: Vector2i) -> bool:
	return tile(c) == "H" or obstacle(c) != ""

func _set_tile(c: Vector2i, ch: String) -> void:
	var row: String = world[c.y]
	world[c.y] = row.substr(0, c.x) + ch + row.substr(c.x + 1)

func tile(cell: Vector2i) -> String:
	if cell.x < 0 or cell.y < 0 or cell.x >= WORLD_W or cell.y >= WORLD_H: return "H"
	return String(world[cell.y])[cell.x]

func start_cell() -> Vector2i:
	return lander

func poi_at(cell: Vector2i) -> Dictionary:
	for p in pois:
		if p["pos"] == cell: return p
	return {}

func target_at(cell: Vector2i) -> Dictionary:
	return poi_at(cell)

## Reveals cells around c. Returns the POIs found for the first time.
func reveal(c: Vector2i, r: float) -> Array:
	var found := []
	var ri := int(ceil(r))
	for dy in range(-ri, ri + 1):
		for dx in range(-ri, ri + 1):
			var cell := c + Vector2i(dx, dy)
			if Vector2(dx, dy).length() > r + 0.01: continue
			if cell.x < 0 or cell.y < 0 or cell.x >= WORLD_W or cell.y >= WORLD_H: continue
			if not revealed.has(cell):
				revealed[cell] = true
				var p := poi_at(cell)
				if not p.is_empty():
					found.append(p)
					log_add("Found %s." % p["label"])
	return found

func is_revealed(cell: Vector2i) -> bool:
	return revealed.has(cell)

## Distance to the nearest POI not yet revealed (for the scanner beep). 99 if none.
func scanner(from: Vector2i) -> float:
	var best := 99.0
	for p in pois:
		if revealed.has(p["pos"]): continue
		best = min(best, Vector2(from).distance_to(Vector2(p["pos"])))
	return best

func passable(cell: Vector2i) -> bool:
	return tile(cell) != "H" or cell == lander

## Robot move (WASD). Returns {moved, found:[], lost:bool}
func scout_move(dir: Vector2i, free := false) -> Dictionary:
	var out := {"moved": false, "found": [], "lost": false}
	if scout.is_empty() or scout["lost"] or (scout["moves"] <= 0 and not free): return out
	var to: Vector2i = scout["pos"] + dir
	if robot_blocked(to): return out
	scout["pos"] = to
	if not free: scout["moves"] -= 1
	out["moved"] = true
	out["found"] = reveal(to, float(dv("reveal")) - (1.0 if dust_today else 0.0))
	# robot docking at the lander with a charging station: battery back to full
	if to == lander and has("charger") and recharges_left > 0 and scout["moves"] < robot_moves() - 5:
		scout["moves"] = robot_moves()
		recharges_left -= 1
		out["recharged"] = true
	if not free and relay_distance(to) > RELAY_RANGE and randf() < 0.07 + (0.08 if dust_today else 0.0):
		scout["lost"] = true
		out["lost"] = true
		log_add("The scout robot lost its signal far from the habitat.", true)
	return out

const WORLD_HOUR_SCALE := 0.2   # one open-world cell is ~1/5 of an old map cell

## Suit hours to cross one cell. veh "?" = the vehicle of the active EVA.
## Distance to the closest radio link: the lander, or a relay beacon (beacons count as closer).
func relay_distance(c: Vector2i) -> float:
	var d := Vector2(c).distance_to(Vector2(lander))
	var br := float(comp["beacon"].get("relay_range_cells", 8)) if comp.has("beacon") else 8.0
	for b in beacons:
		d = min(d, Vector2(c).distance_to(Vector2(b)) + (RELAY_RANGE - br))
	return d

func can_deploy_beacon() -> String:
	if eva.is_empty(): return "Crew must be outside."
	if beacons_left <= 0: return "No beacons left."
	var c: Vector2i = eva["pos"]
	if Vector2(c).distance_to(Vector2(lander)) < 4.0: return "Too close to the lander."
	for b in beacons:
		if Vector2(c).distance_to(Vector2(b)) < 4.0: return "Another beacon is close."
	return ""

func deploy_beacon() -> void:
	var c: Vector2i = eva["pos"]
	beacons.append(c)
	beacons_left -= 1
	eva["used"] += 0.5
	reveal(c, 3.0)
	log_add("Relay beacon installed.")

func crew_hours_per_cell(cell: Vector2i, veh := "?") -> float:
	var hrs = D["map"]["walk_hours_per_cell"]
	var h := float(hrs.get(tile(cell), 0.5)) * WORLD_HOUR_SCALE
	if veh == "?": veh = eva.get("vehicle", "") if not eva.is_empty() else ""
	var f := 1.0
	if veh != "": f = float(comp[veh]["travel_time_factor"])
	if veh == "" and obstacle(cell) == "boulder": h += 0.3
	return h * f * (eva.get("slow", 1.0) if not eva.is_empty() else 1.0)

## Crew path through revealed, passable cells.
func crew_path(from: Vector2i, to: Vector2i) -> Array:
	var a := AStarGrid2D.new()
	a.region = Rect2i(0, 0, WORLD_W, WORLD_H)
	a.cell_size = Vector2(16, 16)
	a.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	a.update()
	var hrs = D["map"]["walk_hours_per_cell"]
	for y in WORLD_H:
		for x in WORLD_W:
			var c := Vector2i(x, y)
			var veh: String = eva.get("vehicle", "") if not eva.is_empty() else ""
			if not revealed.has(c) or crew_blocked(c, veh):
				a.set_point_solid(c, true)
			else:
				a.set_point_weight_scale(c, float(hrs.get(tile(c), 0.5)) * 4.0)
	if a.is_point_solid(to) or a.is_point_solid(from): return []
	return a.get_id_path(from, to)

func path_hours(path: Array, veh := "?") -> float:
	var t := 0.0
	for i in range(1, path.size()):
		t += crew_hours_per_cell(path[i], veh)
	return t

## Suit hours per astronaut per sol (8 h, or less in a dust storm). Each person can go out
## several times a sol until their own suit budget is used; the other pair has a full budget.
func eva_cap() -> float:
	var cap := float(D["map"]["eva_hours"])
	if today.get("eva_cap", 0.0) > 0.0: cap = today["eva_cap"]
	return cap + up("suits") + (1.0 if combo("suitrack") else 0.0)

func suit_left(id: String) -> float:
	return max(0.0, eva_cap() - float(today.get("suit_" + id, 0.0)))

func team_suit_left(team: Array) -> float:
	var m := eva_cap()
	for id in team: m = min(m, suit_left(id))
	return m

func eva_begin(team: Array, vehicle: String) -> String:
	if today.get("eva_blocked", false): return "No EVA today."
	if team.size() < 2: return "Pick 2 crew."
	if team.size() > max_team(): return "Max %d crew." % max_team()
	for id in team:
		if not can_eva(id): return "%s cannot go out." % member(id)["name"]
	if team_suit_left(team) < 1.0: return "Their suits are empty today. Send the other pair."
	eva = {"team": team.duplicate(), "vehicle": vehicle, "pos": lander, "used": 0.0, "cap": team_suit_left(team),
		"slow": 1.0, "energy": float(comp[vehicle]["energy_per_eva_kwh"]) if vehicle != "" else 0.0, "found_bonus": false}
	return ""

func eva_left() -> float:
	return 0.0 if eva.is_empty() else float(eva["cap"]) - float(eva["used"])

## One crew step. Returns {"found":[], "event":{}, "out_of_time":bool}
func eva_step(cell: Vector2i) -> Dictionary:
	var out := {"found": [], "event": {}, "out_of_time": false}
	eva["used"] += crew_hours_per_cell(cell)
	eva["pos"] = cell
	out["found"] = reveal(cell, 2.0)
	if not scout.is_empty() and scout["lost"] and Vector2(cell).distance_to(Vector2(scout["pos"])) <= 1.01:
		scout["lost"] = false
		scout["moves"] = max(int(scout["moves"]), 15)
		out["recovered"] = true
		log_add("The crew walked out and recovered the scout robot.")
	if eva_left() <= 0.0 and cell != lander:
		out["out_of_time"] = true
		return out
	out["event"] = roll_walk_event(cell)
	return out

const WALK_EVENTS := {
	"dust_devil": {"title": "Dust devil", "text": "A dust devil crosses the route.",
		"options": [["wait", "WAIT IT OUT", "-1 h of suit time"], ["push", "PUSH THROUGH", "-8 condition to the team"]]},
	"suit_leak": {"title": "Suit leak", "text": "A suit reports a slow pressure leak.",
		"options": [["patch", "PATCH IT", "-1.5 h (-0.5 h with Tanaka)"], ["back", "HEAD BACK NOW", "Auto-return to the lander"], ["ignore", "IGNORE IT", "-15 condition, risky"]]},
	"ankle": {"title": "Twisted ankle", "text": "Loose rock: an astronaut twists an ankle.",
		"options": [["slow", "SLOW DOWN", "Walking takes 50% longer"], ["treat", "FIRST AID", "-1 h (Duarte: no slowdown)"], ["back", "GO BACK", "Auto-return to the lander"]]},
	"find": {"title": "Unexpected find", "text": "A dark, heavy rock. Maybe a meteorite!",
		"options": [["collect", "COLLECT IT", "-1 h, +6 science, +10 Mb"], ["skip", "MOVE ON", "No cost"]]},
	"stuck": {"title": "Rover stuck", "text": "The rover sinks into soft sand.",
		"options": [["dig", "DIG IT OUT", "-2 h of suit time"], ["walk", "LEAVE IT, WALK", "Rest of the EVA on foot"]]},
}

func roll_walk_event(cell: Vector2i) -> Dictionary:
	var t := tile(cell)
	var r := randf() / float(dv("walk"))
	var id := ""
	if eva["vehicle"] != "" and t == "S" and r < 0.12: id = "stuck"
	elif eva["vehicle"] == "" and (t == "R") and r < 0.03: id = "ankle"
	elif r < 0.012: id = "dust_devil"
	elif r < 0.02: id = "suit_leak"
	elif r < 0.03 and not eva["found_bonus"]: id = "find"
	if id == "" or today.get("walk_events", 0) >= 2: return {}
	today["walk_events"] = today.get("walk_events", 0) + 1
	var e: Dictionary = WALK_EVENTS[id].duplicate(true)
	e["id"] = id
	return e

## Applies a walk-event choice. Returns [text, auto_return:bool]
func apply_walk(e: Dictionary, opt: String) -> Array:
	var team: Array = eva["team"]
	match e["id"]:
		"dust_devil":
			if opt == "wait": eva["used"] += 1.0; return ["You wait until it passes.", false]
			for id in team: member(id)["cond"] -= 8.0
			return ["Sand everywhere, but you made it.", false]
		"suit_leak":
			if opt == "patch":
				eva["used"] += 0.5 if "tanaka" in team else 1.5
				return ["Leak sealed.", false]
			if opt == "back": return ["Heading back to the lander.", true]
			var who = member(team.pick_random())
			who["cond"] -= 15.0
			log_add("Ignored a suit leak: %s was hurt." % who["name"], true)
			return ["%s feels dizzy. -15." % who["name"], false]
		"ankle":
			if opt == "slow":
				eva["slow"] = 1.5
				return ["Slower pace from now on.", false]
			if opt == "treat":
				eva["used"] += 1.0
				if not "duarte" in team: eva["slow"] = 1.25
				return ["Ankle wrapped." + ("" if "duarte" in team else " Still a bit slow."), false]
			return ["Heading back to the lander.", true]
		"find":
			if opt == "collect":
				eva["used"] += 1.0
				eva["found_bonus"] = true
				sample_points += 6.0
				data_buffer += 10.0; data_gen += 10.0
				log_add("Collected an unexpected meteorite.")
				return ["Sample bagged! +6 science.", false]
			return ["You mark it on the map and move on.", false]
		"stuck":
			if opt == "dig": eva["used"] += 2.0; return ["Rover free again.", false]
			eva["vehicle"] = ""
			return ["Rover left behind. Walking now.", false]
	return ["", false]

func can_sample() -> String:
	if eva.is_empty(): return "Start an EVA first."
	var p := poi_at(eva["pos"])
	if p.is_empty(): return "Stand on a target."
	if visits(p["id"]) >= VISITS_PER_TARGET: return "Already fully sampled."
	if eva_left() < float(D["map"]["work_hours_per_sample"]): return "Not enough suit time."
	return ""

## Sample the target the crew is standing on. Returns result text.
func sample() -> String:
	var p := poi_at(eva["pos"])
	var team: Array = eva["team"]
	var sci := preview_science(p, team)
	sample_points += sci
	var inst := 0.0
	var mb := 20.0
	if has("spectrometer") and not today.get("off_spectrometer", false):
		inst += float(comp["spectrometer"]["science_bonus"]) / VISITS_PER_TARGET; mb += float(comp["spectrometer"]["data_mb"])
		eva["energy"] += float(comp["spectrometer"]["energy_per_use_kwh"])
	if has("gpr") and p["type"] == "ice":
		inst += float(comp["gpr"]["science_bonus"]) / VISITS_PER_TARGET; mb += float(comp["gpr"]["data_mb"])
		eva["energy"] += float(comp["gpr"]["energy_per_use_kwh"])
	if has("field_kit"): eva["energy"] += float(comp["field_kit"]["energy_per_use_kwh"])
	instrument_points += inst
	data_buffer += mb
	data_gen += mb
	visited[p["id"]] = visits(p["id"]) + 1
	eva["used"] += float(D["map"]["work_hours_per_sample"])
	var s := stats()
	if s["sample_mult"] < 1.0 and has("field_kit") and has("sample_containers"):
		log_add("Layout cut the value of samples at %s (x%.2f)." % [p["label"], s["sample_mult"]], true)
	if p["type"] == "ice" and not has("gpr"):
		log_add("No radar: the buried ice could not be confirmed.", true)
	log_add("Sampled %s (%d/%d)." % [p["label"], visits(p["id"]), VISITS_PER_TARGET])
	return "%s: +%.0f science, +%.0f Mb (%d/%d)" % [p["label"], sci + inst, mb, visits(p["id"]), VISITS_PER_TARGET]

## Ends the EVA (back at the lander, or rescued). Returns result lines.
func eva_end(rescued := false) -> Array:
	var lines := []
	if eva.is_empty(): return lines
	var team: Array = eva["team"]
	var used: float = eva["used"]
	var per_h := float(D["condition_rules"].get("eva_cost_per_hour", 4))
	for id in team:
		var m := member(id)
		var cost := float(D["condition_rules"]["eva_cost"]) + used * per_h
		if id == "okoye" and used > 5.0: cost *= 1.25
		if rescued: cost += 20.0
		m["cond"] -= cost
		m["dose"] += used * 0.3
	if today.get("spe_outside", false):
		var loss := 30.0 if eva["vehicle"] != "rover_pressurized" else 10.0
		for id in team: member(id)["cond"] -= loss
		lines.append("Radiation hit the EVA crew (-%d)." % int(loss))
		log_add("Ignored the solar storm: EVA crew took -%d condition." % int(loss), true)
	if today.get("dust_push", false) and randf() < 0.3:
		for id in team: member(id)["cond"] -= 15.0
		lines.append("Dust damaged a suit seal (-15).")
		log_add("Pushed on in the dust storm: suit damage.", true)
	if rescued:
		lines.append("Suit time ran out! They walked back on emergency oxygen (-20).")
		log_add("Suit time ran out far from the lander; the crew walked back on emergency oxygen.", true)
	if eva["vehicle"] != "": vehicle_uses += 1
	today["eva_energy"] = eva["energy"]
	today["eva_done"] = true
	for id in team: today["suit_" + id] = float(today.get("suit_" + id, 0.0)) + used
	lines.push_front("EVA over: %.1f h outside." % used)
	log_add("EVA with %s, %.1f h." % [", ".join(team.map(func(i): return member(i)["name"])), used])
	eva = {}
	return lines

func visits(tid: String) -> int:
	return int(visited.get(tid, 0))

func preview_science(target: Dictionary, team: Array) -> float:
	var s := stats()
	var base := float(target["science"]) / VISITS_PER_TARGET
	var v := base
	if not has("field_kit") or not has("sample_containers"):
		v = base * 0.4  # observations and photos only, no proper samples
	else:
		v = base * s["sample_mult"]
	if target["type"] == "ice" and not has("gpr"): v *= 0.3
	if "okoye" in team: v *= 1.25
	return v

## End of sol: power, supplies, recovery, downlink. Returns summary lines.
func end_sol() -> Array:
	var s := stats()
	var lines := []
	# power
	var solar_mult := 1.0
	if dust_today: solar_mult = float(comp["solar"].get("dust_factor", 0.3))
	solar_mult *= float(today.get("solar_mult", 1.0))
	var net := float(s["energy_base"]) + float(s["solar"]) * solar_mult - float(today.get("eva_energy", 0.0))
	if has("fsp"): net -= float(comp["fsp"]["energy_kwh_sol"]) * (1.0 - float(today.get("fsp_mult", 1.0)))
	if today.get("off_spectrometer", false): net += 3.0
	battery = min(float(s["storage"]), battery + net) if net > 0 else battery + net
	if battery < 0:
		lines.append("Power shortfall %.0f kWh: heaters cut back." % battery)
		log_add("Power ran out on sol %d%s." % [sol, " in the dust storm" if dust_today else ""], true)
		for c in crew:
			if not c["evac"]: c["cond"] -= (12.0 if c["id"] == "tanaka" else 8.0)
		battery = 0.0
	else:
		lines.append("Power %+.0f kWh (battery %.0f)." % [net, battery])
	# supplies
	var outside := 0
	for c in crew:
		if float(today.get("suit_" + c["id"], 0.0)) > 0.0: outside += 1
	var eat := 1.0 + 0.25 * outside + (0.5 if mod("hungry") else 0.0)
	supplies -= eat
	lines.append("Food -%.1f sols (%.0f left)." % [eat, maxf(supplies, 0.0)])
	if supplies < 0:
		lines.append("Out of supplies!")
		log_add("Supplies ran out on sol %d." % sol, true)
		for c in crew:
			if not c["evac"]: c["cond"] -= 15.0
	# recovery: everyone rests a little; Dr. Duarte (and the medkit) treat the most tired person
	var rec := float(D["condition_rules"]["base_recovery_per_sol"])
	for c in crew:
		if c["evac"]: continue
		c["dose"] += 0.7
		var stayed_in := float(today.get("suit_" + c["id"], 0.0)) <= 0.0
		c["cond"] = min(100.0, c["cond"] + rec + (6.0 if stayed_in else 0.0))
	var low := lowest_crew()
	if not low.is_empty():
		var extra := 0.0
		if fit("duarte"): extra += 8.0
		if has("medkit"): extra += float(comp["medkit"]["condition_recovery_bonus"]) * s["med_mult"]
		if "sickbay" in s["combos"]:
			for c in crew:
				if not c["evac"]: c["cond"] = min(100.0, c["cond"] + 4.0)
		low["cond"] = min(100.0, low["cond"] + extra)
	# evacuations
	for c in crew:
		if not c["evac"] and c["cond"] <= 0.0:
			c["evac"] = true
			c["cond"] = 0.0
			lines.append("%s had to be evacuated to the ascent vehicle." % c["name"])
			log_add("%s was evacuated (condition 0)." % c["name"], true)
	# downlink
	var dl := float(s["downlink"])
	if today.get("no_downlink", false): dl = 0.0
	if today.get("relay_missed", false): dl = float(comp["hga"]["downlink_mb_sol"]) if has("hga") else 0.0
	if today.get("relay_prioritize", false):
		data_buffer *= 0.7
	if battery <= 0.0 and net < 0: dl *= 0.5
	var sent := float(min(dl, data_buffer))
	data_buffer -= sent
	data_sent += sent
	if sent > 0: lines.append("Sent %.0f Mb to Earth." % sent)
	return lines

func next_sol() -> void:
	sol += 1
	today = {}
	dust_today = dust_tomorrow
	dust_tomorrow = false
	if sol > stay:
		mission_over = true
		log_add("Ascent on sol %d." % stay)

func unvisited_targets() -> Array:
	var out := []
	for t in pois:
		if visits(t["id"]) < VISITS_PER_TARGET: out.append(t)
	return out

# ---------------- events ----------------
## Rolls the event for the start of this sol. Returns event dict or {}.
func roll_event() -> Dictionary:
	# weather forecast for tomorrow
	var dust_p := float(window_data()["dust_event_chance"]) * 0.5 * (2.0 if mod("storms") else 1.0)
	if randf() < dust_p: dust_tomorrow = true
	if sol < 2: return {}
	var cands := []
	if dust_today: cands.append("dust_storm")
	var low := lowest_crew()
	if not low.is_empty() and low["cond"] < 50.0 and randf() < 0.6: cands.append("medical_issue")
	if sol > 3 and not spe_happened and randf() < 0.18: cands.append("solar_particle_event")
	if vehicle_uses >= 2 and randf() < (0.1 + 0.05 * vehicle_uses + vehicle_fragile) * (0.4 if combo("pitcrew") else 1.0): cands.append("equipment_failure")
	if has("uhf") and not has("hga") and randf() < float(comp["uhf"]["relay_pass_loss_chance"]): cands.append("relay_pass_missed")
	# events that depend on what you packed (one of them at most)
	var cargo := []
	for id in CARGO_EVENTS:
		var ce: Dictionary = CARGO_EVENTS[id]
		var ok := false
		for need in ce["needs"]:
			if has(need) and not (need.begins_with("rover") and vehicles_broken.has(need)): ok = true
		if ok and not events_seen.has(id) or (ok and ce.get("repeat", false)):
			cargo.append(id)
	cargo.shuffle()
	if not cargo.is_empty() and randf() < float(dv("cargo_p")): cands.append(cargo[0])
	if cands.is_empty(): return {}
	# dust storm first (it is visible), otherwise a random one so sols feel different
	var id = cands[0] if cands[0] == "dust_storm" else cands.pick_random()
	if CARGO_EVENTS.has(id):
		events_seen.append(id)
		var ev: Dictionary = CARGO_EVENTS[id].duplicate(true)
		ev["id"] = id
		var opts := []
		for o in ev["options"]: opts.append({"id": o[0], "label": o[1], "cost": o[2]})
		ev["options"] = opts
		return ev
	for e in D["events"]:
		if e["id"] == id:
			events_seen.append(id)
			if id == "solar_particle_event": spe_happened = true
			return e
	return {}

func lowest_crew() -> Dictionary:
	var best := {}
	for c in crew:
		if c["evac"]: continue
		if best.is_empty() or c["cond"] < best["cond"]: best = c
	return best

func usable_vehicle() -> String:
	if today.get("no_vehicle", false): return ""
	for v in ["rover_pressurized", "rover_open"]:
		if has(v) and not vehicles_broken.has(v): return v
	return ""

## Options shown for an event (Vega shows the last option only while fit).
func event_options(e: Dictionary) -> Array:
	var opts: Array = e["options"].duplicate(true)
	for o in opts:
		o["disabled"] = ""
	if e["id"] == "equipment_failure":
		if spares_left <= 0: opts[0]["disabled"] = "no spare parts"
	if e["id"] == "medical_issue":
		if not has("medkit"): opts[0]["cost"] = "No medkit: smaller effect; skip EVA"
	if opts.size() > 2 and not fit("vega"):
		opts.resize(2)
	return opts

## Applies an option. Returns result text.
## Events tied to the cargo you chose (preparation is gameplay). "item" = icon shown in the popup.
const CARGO_EVENTS := {
	"reactor_hot": {"title": "Reactor overheating", "needs": ["fsp"], "item": "fsp", "repeat": true,
		"text": "The fission unit runs hot. The radiator is covered in dust.",
		"options": [["throttle", "THROTTLE DOWN", "Reactor at 50% power today"], ["vent", "SEND TANAKA", "Tanaka cleans it: no EVA for him today"], ["ignore", "IGNORE IT", "30%: reactor shuts off today"]]},
	"dusty_panels": {"title": "Dusty solar panels", "needs": ["solar"], "item": "solar", "repeat": true,
		"text": "A thin layer of dust covers the solar arrays.",
		"options": [["clean", "CLEAN THEM", "-1 h of suit time for 2 crew"], ["leave", "LEAVE IT", "Solar power -40% today"]]},
	"filter_clog": {"title": "Life support filter", "needs": ["eclss"], "item": "eclss",
		"text": "The air recycling filter is clogged with fine dust.",
		"options": [["replace", "REPLACE IT", "Uses spare parts"], ["fix", "TANAKA FIXES IT", "No EVA for Tanaka today"], ["degraded", "RUN DEGRADED", "-2 sols of supplies"]]},
	"tank_leak": {"title": "Water tank leak", "needs": ["water"], "item": "water",
		"text": "A seam on the water tank is weeping into the dust.",
		"options": [["patch", "PATCH IT", "Uses spare parts"], ["move", "MOVE THE WATER", "Lose the radiation shield"], ["accept", "ACCEPT THE LOSS", "-2 sols of supplies"]]},
	"antenna_off": {"title": "Antenna off target", "needs": ["hga", "uhf"], "item": "hga",
		"text": "A gust knocked the antenna off its pointing.",
		"options": [["realign", "REALIGN IT", "-1 h of suit time for 2 crew"], ["wait", "WAIT", "No data sent to Earth today"]]},
	"rover_flat": {"title": "Rover wheel puncture", "needs": ["rover_open", "rover_pressurized"], "item": "rover_open",
		"text": "A sharp rock tore a rover wheel.",
		"options": [["repair", "REPAIR IT", "Uses spare parts"], ["walk", "WALK TODAY", "No rover today"], ["tape", "QUICK PATCH", "Rover works, but may fail again"]]},
	"crate_dent": {"title": "Damaged supply crate", "needs": ["crate"], "item": "crate",
		"text": "A crate cracked on landing. Some food is spoiled.",
		"options": [["check", "SORT IT OUT", "-1 sol of supplies"]]},
	"spectro_hint": {"title": "Good news: mineral signal", "needs": ["spectrometer"], "item": "spectrometer",
		"text": "The spectrometer spots a promising mineral signal nearby!",
		"options": [["mark", "MARK IT ON THE MAP", "Reveals one hidden target"]]},
	"clear_sky": {"title": "Good news: clear sky", "needs": ["solar"], "item": "solar", "repeat": true,
		"text": "The sky is unusually clear today.",
		"options": [["enjoy", "GREAT!", "Solar power +50% today"]]},
}

func _suit_cost_two(h: float) -> void:
	var n := 0
	for c in crew:
		if n < 2 and can_eva(c["id"]):
			today["suit_" + c["id"]] = float(today.get("suit_" + c["id"], 0.0)) + h
			n += 1

func _apply_cargo_event(e: Dictionary, option_id: String) -> String:
	match option_id:
		"throttle": today["fsp_mult"] = 0.5; return "Reactor throttled to 50% today."
		"vent":
			if fit("tanaka"):
				today["no_eva_tanaka"] = true
				return "Tanaka cleans the radiator. He stays in today."
			member("tanaka")["cond"] -= 10.0
			return "Without Tanaka it takes longer. -10 to Tanaka."
		"ignore":
			if randf() < 0.3:
				today["fsp_mult"] = 0.0
				log_add("Ignored an overheating reactor: it shut down for a sol.", true)
				return "The reactor shut itself off for today!"
			return "It cooled down on its own. Lucky."
		"clean": _suit_cost_two(1.0); return "Panels cleaned. Two suits used 1 h."
		"leave": today["solar_mult"] = 0.6; return "Solar power -40% today."
		"replace", "patch", "repair":
			if spares_left > 0:
				spares_left -= 1
				return "Fixed with spare parts."
			if option_id == "repair":
				today["no_vehicle"] = true
				return "No spare parts! The rover stays parked today."
			supplies -= 2.0
			log_add("No spare parts for a %s: supplies lost." % String(e["title"]).to_lower(), true)
			return "No spare parts! -2 sols of supplies."
		"fix": today["no_eva_tanaka"] = true; return "Tanaka fixes it. He stays in today."
		"degraded", "accept":
			supplies -= 2.0
			return "-2 sols of supplies."
		"move":
			shield_lost = true
			log_add("Water moved away from the shelter: no radiation shield.", true)
			return "Water saved, but the shelter lost its shield."
		"realign": _suit_cost_two(1.0); return "Antenna realigned."
		"wait": today["no_downlink"] = true; return "No data goes home today."
		"walk": today["no_vehicle"] = true; return "The rover rests today."
		"tape": vehicle_fragile += 0.2; return "Patched. It may fail again."
		"check": supplies -= 1.0; return "-1 sol of supplies."
		"mark":
			for p in pois:
				if not revealed.has(p["pos"]):
					reveal(p["pos"], 1.0)
					if not p["pos"] in marks: marks.append(p["pos"])
					return "Found %s! It is marked on the map (M)." % p["label"]
			return "Nothing new nearby."
		"enjoy": today["solar_mult"] = 1.5; return "Solar power +50% today."
	return ""

func apply_event(e: Dictionary, option_id: String) -> String:
	if CARGO_EVENTS.has(e["id"]): return _apply_cargo_event(e, option_id)
	var s := stats()
	var rad: float = s["rad_mult"]
	match e["id"]:
		"dust_storm":
			match option_id:
				"shelter_in_place":
					today["eva_blocked"] = true
					return "Everyone stays inside. No EVA today."
				"short_eva":
					today["eva_cap"] = 3.0
					return "EVA limited to 3 hours near the lander."
				"push_on":
					today["dust_push"] = true
					return "The plan goes on. Watch the suits."
		"solar_particle_event":
			match option_id:
				"use_shelter":
					today["eva_blocked"] = true
					for c in crew:
						if c["evac"]: continue
						c["cond"] -= 12.0 * rad; c["dose"] += 40.0 * rad
					log_add("Solar storm: shelter cut the dose to x%.2f." % rad, rad > 0.5)
					return "Crew in the shelter. Dose x%.2f." % rad
				"rush_back":
					today["eva_blocked"] = true
					for c in crew:
						if c["evac"]: continue
						c["cond"] -= 12.0; c["dose"] += 40.0
					log_add("Solar storm: no shielded refuge, crew took the full dose.", true)
					return "EVA cancelled. Crew took a moderate dose."
				"ignore":
					today["spe_outside"] = true
					for c in crew:
						if c["evac"]: continue
						c["dose"] += 20.0
					return "EVA goes on. Outside crew will be exposed."
		"equipment_failure":
			var v := usable_vehicle()
			var what: String = comp[v]["name"] if v != "" else "EVA suit"
			match option_id:
				"repair":
					spares_left -= 1
					vehicle_uses = 0
					if not fit("tanaka"):
						today["eva_blocked"] = true
						return "%s repaired, but it took all day (Tanaka unavailable)." % what
					return "Tanaka repaired the %s quickly." % what
				"improvise":
					vehicle_uses = 0
					vehicle_fragile += 0.2
					log_add("Improvised fix on the %s: it is now less reliable." % what, true)
					return "Fixed with tape and wire. It may fail again."
				"drop_equipment":
					if v != "": vehicles_broken[v] = true
					log_add("Lost the %s after a failure." % what, true)
					return "The %s is out of service for the mission." % what
		"medical_issue":
			var m := lowest_crew()
			if m.is_empty(): return ""
			match option_id:
				"treat":
					var gain := 15.0
					if has("medkit"): gain = 30.0 * float(s["med_mult"])
					if fit("duarte"): gain += 10.0
					m["cond"] = min(100.0, m["cond"] + gain)
					today["no_eva_" + m["id"]] = true
					return "%s treated (+%d). No EVA for them today." % [m["name"], int(gain)]
				"rest":
					m["cond"] = min(100.0, m["cond"] + 10.0)
					today["no_eva_" + m["id"]] = true
					return "%s rests (+10)." % m["name"]
				"continue":
					if randf() < 0.5:
						m["cond"] = min(m["cond"], 15.0)
						log_add("%s kept working while ill and collapsed." % m["name"], true)
						return "%s collapsed. Condition 15." % m["name"]
					return "%s pushes through. Lucky this time." % m["name"]
		"relay_pass_missed":
			match option_id:
				"buffer":
					today["relay_missed"] = true
					return "Data stays in memory until the next pass."
				"prioritize":
					today["relay_prioritize"] = true
					log_add("Relay pass missed: low-value data was dropped.", true)
					return "Only the best data is sent; some is lost."
	return ""

# ---------------- report ----------------
func report() -> Dictionary:
	var s := stats()
	var o := objective_data()
	# science
	var goals := goal_types()
	var done := goals_done()
	var primary := done.size() >= goals.size()
	var secondary := 0
	for t in pois:
		if not visited.has(t["id"]): continue
		if t["type"] in o["secondary"]: secondary += 1
	var sent_frac := 1.0 if data_gen <= 0.0 else clampf(data_sent / data_gen, 0.0, 1.0)
	var sci_raw := sample_points + instrument_points * sent_frac
	sci_raw += float(o["primary_points"]) * float(done.size()) / float(goals.size()) + 5.0 * maxf(0.0, done.size() - 1)
	sci_raw += 5.0 * secondary
	# the bar scales with the stay and the level: a 10-sol medium mission needs ~127 raw points,
	# so every sol has to count (the old 90 let players finish in half the time)
	var sci_k: float = 165.0 * float(stay) / 10.0 * {"easy": 0.65, "medium": 0.9, "hard": 1.0}[difficulty]
	var science: float = clamp(sci_raw / sci_k * 35.0, 0.0, 35.0)
	# crew
	var evac := 0
	var cond_sum := 0.0
	for c in crew:
		if c["evac"]: evac += 1
		else: cond_sum += c["cond"]
	var alive: int = crew.size() - evac
	var avg := cond_sum / maxf(alive, 1.0)
	var crew_score: float = clamp(25.0 - 8.0 * evac - (100.0 - avg) / 10.0, 0.0, 25.0)
	# engineering
	var eng := 0.0
	if s["mass_margin_pct"] >= 10.0: eng += 5.0
	if s["energy"] >= 0: eng += 5.0
	var bad := 0
	for a in s["adj"]:
		if a["rule"] != "shielding": bad += 1
	if bad == 0: eng += 5.0
	if s["rad_mult"] <= 0.5: eng += 5.0
	# efficiency
	var eff: float = clamp((s["budget"] - s["cost"]) / s["budget"] * 20.0, 0.0, 10.0) + 10.0 * sent_frac
	var total := science + crew_score + eng + eff
	var min_sci := float(D["scoring"]["seals"].get("min_science", 27))
	var seal := "MISSION ABORTED"
	if science < min_sci and evac < 2: seal = "MISSION FAILED"
	elif total >= float(D["scoring"]["seals"]["complete"]) and evac == 0 and primary: seal = "MISSION COMPLETE"
	elif total >= float(D["scoring"]["seals"]["partial"]) and evac < 2: seal = "PARTIAL SUCCESS"
	# cause chain: up to 3 logged causes + unvisited targets
	var causes := []
	for l in mission_log:
		if l["cause"] and not causes.has(l["text"]): causes.append(l["text"])
	var left := unvisited_targets()
	if not left.is_empty():
		causes.append("The ascent window on sol %d left %s %s." % [stay, left[0]["label"], "unvisited" if visits(left[0]["id"]) == 0 else "half-sampled"])
	if not primary:
		var miss: Array = []
		for g in goals:
			if not g in done: miss.append(g)
		causes.push_front("Goals not reached: no %s sample (%d of %d goals)." % [" or ".join(miss), done.size(), goals.size()])
	if science < min_sci:
		causes.push_front("Not enough science: %d of 35 points (at least %d needed)." % [int(science), int(min_sci)])
	if causes.is_empty():
		causes.append("Every choice held up. Margins carried the crew home.")
	var analog := {"name": o["real_analog"], "text": "Real mission with a similar goal."}
	for a in D["report"]["real_analogs"]:
		if String(o["real_analog"]).begins_with(a["name"]): analog = a
	return {"science": science, "crew": crew_score, "eng": eng, "eff": eff, "total": total,
		"seal": seal, "causes": causes.slice(0, 3), "analog": analog, "evac": evac,
		"primary": primary, "sent": data_sent, "gen": data_gen, "goals": goals, "done": done}

## Back to the trade study keeping the cargo layout.
func redesign() -> void:
	attempt += 1
	if not saved_design.is_empty(): placements = saved_design.duplicate(true)
