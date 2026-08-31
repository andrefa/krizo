extends Node

const SAVE_PATH := "user://krizo_save.json"

var data := {
	"coins": 0,
	"best_altitude": 0,
	"runs": 0,
	"upgrades": {
		"tank": 0,
		"thrust": 0,
		"control": 0,
		"efficiency": 0
	}
}

func _ready() -> void:
	load_save()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	data = _merge_defaults(parsed)

func save() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func add_coins(amount: int) -> void:
	data.coins = int(data.coins) + amount
	save()

func finish_run(altitude: int, earned_coins: int) -> void:
	data.coins = int(data.coins) + earned_coins
	data.best_altitude = max(int(data.best_altitude), altitude)
	data.runs = int(data.runs) + 1
	save()

func upgrade_level(key: String) -> int:
	return int(data.upgrades.get(key, 0))

func upgrade_cost(key: String) -> int:
	var level := upgrade_level(key)
	return 25 + level * level * 20 + level * 15

func buy_upgrade(key: String) -> bool:
	if not data.upgrades.has(key):
		return false
	var cost := upgrade_cost(key)
	if int(data.coins) < cost:
		return false
	data.coins = int(data.coins) - cost
	data.upgrades[key] = upgrade_level(key) + 1
	save()
	return true

func reset_progress() -> void:
	data = _defaults()
	save()

func _merge_defaults(raw: Dictionary) -> Dictionary:
	var merged := _defaults()
	for key in ["coins", "best_altitude", "runs"]:
		if raw.has(key):
			merged[key] = raw[key]
	if raw.has("upgrades") and typeof(raw.upgrades) == TYPE_DICTIONARY:
		for key in merged.upgrades.keys():
			if raw.upgrades.has(key):
				merged.upgrades[key] = raw.upgrades[key]
	return merged

func _defaults() -> Dictionary:
	return {
		"coins": 0,
		"best_altitude": 0,
		"runs": 0,
		"upgrades": {"tank": 0, "thrust": 0, "control": 0, "efficiency": 0}
	}
