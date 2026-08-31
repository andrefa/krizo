extends Node2D

@onready var krizo: KrizoPlayer = $World/Krizo as KrizoPlayer
@onready var generator: RunGenerator = $World/RunGenerator as RunGenerator
@onready var camera: Camera2D = $Camera2D
@onready var background: ColorRect = $Background
@onready var altitude_label: Label = $HUD/Top/Altitude
@onready var best_label: Label = $HUD/Top/Best
@onready var coin_label: Label = $HUD/Top/Coins
@onready var fuel_bar: ProgressBar = $HUD/Top/Fuel
@onready var region_label: Label = $HUD/Region
@onready var boost_label: Label = $HUD/BoostStatus
@onready var start_panel: Control = $HUD/StartPanel
@onready var game_over: Control = $HUD/GameOver
@onready var pause_panel: Control = $HUD/PausePanel
@onready var game_over_stats: Label = $HUD/GameOver/Panel/VBox/Stats
@onready var shop_panel: Control = $HUD/ShopPanel
@onready var shop_info: Label = $HUD/ShopPanel/Panel/VBox/Info

var started: bool = false
var finished: bool = false
var max_altitude: int = 0
var current_region: String = "BASE SUBTERRÂNEA"
var boost_message_time: float = 0.0

func _ready() -> void:
	krizo.process_mode = Node.PROCESS_MODE_DISABLED
	krizo.altitude_changed.connect(_on_altitude_changed)
	krizo.fuel_changed.connect(_on_fuel_changed)
	krizo.crashed.connect(_on_crashed)
	krizo.coin_collected.connect(_on_coin_collected)
	krizo.boost_activated.connect(_on_boost_activated)
	krizo.highspeed_changed.connect(_on_highspeed_changed)
	krizo.launch_finished.connect(_on_launch_finished)
	game_over.visible = false
	pause_panel.visible = false
	shop_panel.visible = false
	boost_label.visible = false
	region_label.text = current_region
	_refresh_meta_ui()
	_update_background(0)

func _process(delta: float) -> void:
	if not started or finished:
		return

	# Dynamic third-person camera: vertical progress remains primary, but horizontal
	# movement is no longer constrained to the original screen width.
	var target_y: float = minf(camera.global_position.y, krizo.global_position.y - GameBalance.CAMERA_LEAD)
	camera.global_position.y = lerpf(camera.global_position.y, target_y, 5.0 * delta)
	camera.global_position.x = lerpf(camera.global_position.x, krizo.global_position.x, 3.2 * delta)
	background.position = camera.global_position - Vector2(360.0, 640.0)

	generator.update_for_player(krizo.global_position, max_altitude)

	# Per the GDD, impacts are recoverable. The run ends only if Krizo falls
	# beyond the allowed lower edge of the camera.
	if krizo.global_position.y > camera.global_position.y + 850.0:
		krizo.crash()

	if boost_message_time > 0.0:
		boost_message_time = maxf(0.0, boost_message_time - delta)
		if boost_message_time <= 0.0:
			boost_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and started and not finished:
		_toggle_pause()

func _on_start_pressed() -> void:
	started = true
	start_panel.visible = false
	krizo.process_mode = Node.PROCESS_MODE_INHERIT
	generator.prime()
	krizo.begin_launch()
	region_label.text = "LANÇAMENTO"
	boost_label.text = "IGNIÇÃO!"
	boost_label.visible = true
	boost_message_time = 1.4

func _on_launch_finished() -> void:
	boost_label.text = "VOCÊ ESTÁ NO CONTROLE"
	boost_label.visible = true
	boost_message_time = 1.5

func _on_altitude_changed(meters: int) -> void:
	max_altitude = maxi(max_altitude, meters)
	altitude_label.text = "%04d m" % meters
	_update_region(meters)
	_update_background(meters)

func _on_fuel_changed(ratio: float) -> void:
	fuel_bar.value = ratio * 100.0

func _on_coin_collected(total: int) -> void:
	coin_label.text = "● %d" % total

func _on_boost_activated(boost_name: String) -> void:
	boost_label.text = boost_name.to_upper()
	boost_label.visible = true
	boost_message_time = 1.25

func _on_highspeed_changed(active: bool) -> void:
	if active:
		boost_label.text = "HIGHSPEED MODE"
		boost_label.visible = true
		boost_message_time = 2.0

func _update_region(meters: int) -> void:
	var new_region: String
	if meters < 90:
		new_region = "TÚNEL DE LANÇAMENTO"
	elif meters < 350:
		new_region = "CÉU"
	elif meters < 700:
		new_region = "NUVENS"
	elif meters < 1200:
		new_region = "ALTA ATMOSFERA"
	else:
		new_region = "ESPAÇO"
	if new_region != current_region:
		current_region = new_region
		region_label.text = current_region

func _update_background(meters: int) -> void:
	var color: Color
	if meters < 90:
		var t_tunnel: float = clampf(float(meters) / 90.0, 0.0, 1.0)
		color = Color("2b160e").lerp(Color("80cce4"), t_tunnel)
	elif meters < 700:
		var t_sky: float = clampf(float(meters - 90) / 610.0, 0.0, 1.0)
		color = Color("80cce4").lerp(Color("397ec4"), t_sky)
	elif meters < 1200:
		var t_atmo: float = clampf(float(meters - 700) / 500.0, 0.0, 1.0)
		color = Color("397ec4").lerp(Color("111936"), t_atmo)
	else:
		var t_space: float = clampf(float(meters - 1200) / 900.0, 0.0, 1.0)
		color = Color("111936").lerp(Color("050510"), t_space)
	background.color = color

func _on_crashed() -> void:
	if finished:
		return
	finished = true
	SaveManager.finish_run(max_altitude, krizo.run_coins)
	game_over_stats.text = "%d m\n+%d coins\nBest: %d m" % [max_altitude, krizo.run_coins, SaveManager.best_altitude()]
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

func _on_tank_pressed() -> void:
	_buy_upgrade("tank")

func _on_thrust_pressed() -> void:
	_buy_upgrade("thrust")

func _on_control_pressed() -> void:
	_buy_upgrade("control")

func _on_efficiency_pressed() -> void:
	_buy_upgrade("efficiency")

func _refresh_meta_ui() -> void:
	best_label.text = "BEST %d m" % SaveManager.best_altitude()

func _refresh_shop() -> void:
	shop_info.text = "COINS: %d\n\nTank Lv.%d — %d\nThrust Lv.%d — %d\nControl Lv.%d — %d\nEfficiency Lv.%d — %d" % [
		SaveManager.coins(),
		SaveManager.upgrade_level("tank"), SaveManager.upgrade_cost("tank"),
		SaveManager.upgrade_level("thrust"), SaveManager.upgrade_cost("thrust"),
		SaveManager.upgrade_level("control"), SaveManager.upgrade_cost("control"),
		SaveManager.upgrade_level("efficiency"), SaveManager.upgrade_cost("efficiency")
	]
