extends Node2D

@onready var krizo: CharacterBody2D = $World/Krizo
@onready var generator: Node2D = $World/RunGenerator
@onready var camera: Camera2D = $Camera2D
@onready var altitude_label: Label = $HUD/Top/Altitude
@onready var best_label: Label = $HUD/Top/Best
@onready var coin_label: Label = $HUD/Top/Coins
@onready var fuel_bar: ProgressBar = $HUD/Top/Fuel
@onready var start_panel: Control = $HUD/StartPanel
@onready var game_over: Control = $HUD/GameOver
@onready var pause_panel: Control = $HUD/PausePanel
@onready var game_over_stats: Label = $HUD/GameOver/Panel/VBox/Stats
@onready var shop_panel: Control = $HUD/ShopPanel
@onready var shop_info: Label = $HUD/ShopPanel/Panel/VBox/Info

var started := false
var finished := false
var max_altitude := 0

func _ready() -> void:
	krizo.process_mode = Node.PROCESS_MODE_DISABLED
	krizo.altitude_changed.connect(_on_altitude_changed)
	krizo.fuel_changed.connect(_on_fuel_changed)
	krizo.crashed.connect(_on_crashed)
	krizo.coin_collected.connect(_on_coin_collected)
	game_over.visible = false
	pause_panel.visible = false
	shop_panel.visible = false
	_refresh_meta_ui()

func _process(delta: float) -> void:
	if not started or finished:
		return
	var target_y := min(camera.global_position.y, krizo.global_position.y - GameBalance.CAMERA_LEAD)
	camera.global_position.y = lerp(camera.global_position.y, target_y, 5.0 * delta)
	generator.update_for_player(krizo.global_position.y, max_altitude)
	if krizo.global_position.y > camera.global_position.y + 850.0:
		krizo.crash()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and started and not finished:
		_toggle_pause()

func _on_start_pressed() -> void:
	started = true
	start_panel.visible = false
	krizo.process_mode = Node.PROCESS_MODE_INHERIT
	generator.prime()

func _on_altitude_changed(meters: int) -> void:
	max_altitude = max(max_altitude, meters)
	altitude_label.text = "%04d m" % meters

func _on_fuel_changed(ratio: float) -> void:
	fuel_bar.value = ratio * 100.0

func _on_coin_collected(total: int) -> void:
	coin_label.text = "RUN $%d" % total

func _on_crashed() -> void:
	if finished:
		return
	finished = true
	SaveManager.finish_run(max_altitude, krizo.run_coins)
	game_over_stats.text = "%d m\n+%d coins\nBest: %d m" % [max_altitude, krizo.run_coins, int(SaveManager.data.best_altitude)]
	game_over.visible = true
	_refresh_meta_ui()

func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _toggle_pause() -> void:
	get_tree().paused = not get_tree().paused
	pause_panel.visible = get_tree().paused

func _on_resume_pressed() -> void:
	_toggle_pause()

func _on_shop_pressed() -> void:
	shop_panel.visible = true
	_refresh_shop()

func _on_shop_close_pressed() -> void:
	shop_panel.visible = false

func _buy_upgrade(key: String) -> void:
	SaveManager.buy_upgrade(key)
	_refresh_meta_ui()
	_refresh_shop()

func _on_tank_pressed() -> void: _buy_upgrade("tank")
func _on_thrust_pressed() -> void: _buy_upgrade("thrust")
func _on_control_pressed() -> void: _buy_upgrade("control")
func _on_efficiency_pressed() -> void: _buy_upgrade("efficiency")

func _refresh_meta_ui() -> void:
	best_label.text = "BEST %d m" % int(SaveManager.data.best_altitude)

func _refresh_shop() -> void:
	shop_info.text = "COINS: %d\n\nTank Lv.%d — %d\nThrust Lv.%d — %d\nControl Lv.%d — %d\nEfficiency Lv.%d — %d" % [
		int(SaveManager.data.coins),
		SaveManager.upgrade_level("tank"), SaveManager.upgrade_cost("tank"),
		SaveManager.upgrade_level("thrust"), SaveManager.upgrade_cost("thrust"),
		SaveManager.upgrade_level("control"), SaveManager.upgrade_cost("control"),
		SaveManager.upgrade_level("efficiency"), SaveManager.upgrade_cost("efficiency")
	]
