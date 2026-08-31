extends Node

const SAVE_PATH: String = "user://krizo_save.json"
const META_KEYS: Array[String] = ["coins", "best_altitude", "runs"]

var data: Dictionary = _defaults()

func _ready() -> void:
	load_save()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not parsed is Dictionary:
		return
	data = _merge_defaults(parsed as Dictionary)

func save() -> void:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func add_coins(amount: int) -> void:
	data["coins"] = int(data.get("coins", 0)) + amount
	save()

func finish_run(altitude: int, earned_coins: int) -> void:
	data["coins"] = int(data.get("coins", 0)) + earned_coins
	data["best_altitude"] = maxi(int(data.get("best_altitude", 0)), altitude)
	data["runs"] = int(data.get("runs", 0)) + 1
	if altitude >= 100:
		unlock_achievement("sky_digger", false)
	if altitude >= 700:
		unlock_achievement("thin_air", false)
	if altitude >= 1200:
		unlock_achievement("space_mole", false)
	save()

func coins() -> int:
	return int(data.get("coins", 0))

func best_altitude() -> int:
	return int(data.get("best_altitude", 0))

func runs() -> int:
	return int(data.get("runs", 0))

func upgrade_level(key: String) -> int:
	var upgrades: Dictionary = data.get("upgrades", {}) as Dictionary
	return int(upgrades.get(key, 0))

func upgrade_cost(key: String) -> int:
	var level: int = upgrade_level(key)
	return 25 + level * level * 20 + level * 15

func buy_upgrade(key: String) -> bool:
	var upgrades: Dictionary = data.get("upgrades", {}) as Dictionary
	if not upgrades.has(key):
		return false
	var cost: int = upgrade_cost(key)
	if coins() < cost:
		return false
	data["coins"] = coins() - cost
	upgrades[key] = upgrade_level(key) + 1
	data["upgrades"] = upgrades
	save()
	return true

func discover_region(region: String) -> bool:
	var discoveries: Array = data.get("discoveries", []) as Array
	if discoveries.has(region):
		return false
	discoveries.append(region)
	data["discoveries"] = discoveries
	save()
	return true

func discovery_count() -> int:
	var discoveries: Array = data.get("discoveries", []) as Array
	return discoveries.size()

func unlock_achievement(key: String, save_immediately: bool = true) -> bool:
	var achievements: Array = data.get("achievements", []) as Array
	if achievements.has(key):
		return false
	achievements.append(key)
	data["achievements"] = achievements
	if save_immediately:
		save()
	return true

func achievement_count() -> int:
	var achievements: Array = data.get("achievements", []) as Array
	return achievements.size()

func reset_progress() -> void:
	data = _defaults()
	save()

func _merge_defaults(raw: Dictionary) -> Dictionary:
	var merged: Dictionary = _defaults()
	for key: String in META_KEYS:
		if raw.has(key):
			merged[key] = raw[key]
	var raw_upgrades_value: Variant = raw.get("upgrades", {})
	if raw_upgrades_value is Dictionary:
		var raw_upgrades: Dictionary = raw_upgrades_value as Dictionary
		var merged_upgrades: Dictionary = merged.get("upgrades", {}) as Dictionary
		for key: Variant in merged_upgrades.keys():
			var key_string: String = str(key)
			if raw_upgrades.has(key_string):
				merged_upgrades[key_string] = raw_upgrades[key_string]
		merged["upgrades"] = merged_upgrades
	var raw_discoveries: Variant = raw.get("discoveries", [])
	if raw_discoveries is Array:
		merged["discoveries"] = raw_discoveries
	var raw_achievements: Variant = raw.get("achievements", [])
	if raw_achievements is Array:
		merged["achievements"] = raw_achievements
	return merged

func _defaults() -> Dictionary:
	return {
		"coins": 0,
		"best_altitude": 0,
		"runs": 0,
		"upgrades": {"tank": 0, "thrust": 0, "control": 0, "efficiency": 0},
		"discoveries": [],
		"achievements": []
	}
