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
var best_marker: Node2D

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
	_create_best_marker()

func _process(delta: float) -> void:
	if not started or finished:
		return

	var target_y: float = minf(camera.global_position.y, krizo.global_position.y - GameBalance.CAMERA_LEAD)
	camera.global_position.y = lerpf(camera.global_position.y, target_y, 5.0 * delta)
	camera.global_position.x = lerpf(camera.global_position.x, krizo.global_position.x, 3.2 * delta)
	var target_zoom: Vector2 = Vector2(0.84, 0.84) if krizo.highspeed_time_left > 0.0 else Vector2.ONE
	camera.zoom = camera.zoom.lerp(target_zoom, 2.8 * delta)
	background.position = camera.global_position - Vector2(360.0, 640.0) / camera.zoom
	background.size = Vector2(720.0, 1280.0) / camera.zoom

	if best_marker != null:
		best_marker.position.x = krizo.global_position.x

	generator.update_for_player(krizo.global_position, max_altitude)

	# The original GDD defines failure only as falling beyond the allowed limit.
	if krizo.global_position.y > camera.global_position.y + 850.0 / camera.zoom.y:
		krizo.crash()

	if boost_message_time > 0.0:
		boost_message_time = maxf(0.0, boost_message_time - delta)
		if boost_message_time <= 0.0:
			boost_label.visible = false

func _create_best_marker() -> void:
	var saved_best: int = SaveManager.best_altitude()
	if saved_best <= 0:
		return
	best_marker = Node2D.new()
	best_marker.name = "BestMarker"
	best_marker.position = Vector2(krizo.global_position.x, krizo.start_y - float(saved_best) * GameBalance.PIXELS_PER_METER)
	best_marker.z_index = -1
	$World.add_child(best_marker)

	var line: Line2D = Line2D.new()
	line.width = 3.0
	line.default_color = Color(1.0, 0.78, 0.22, 0.72)
	line.points = PackedVector2Array(Vector2(-330.0, 0.0), Vector2(330.0, 0.0))
	best_marker.add_child(line)

	var marker_label: Label = Label.new()
	marker_label.position = Vector2(-105.0, -36.0)
	marker_label.text = "SEU RECORDE • %d m" % saved_best
	marker_label.add_theme_font_size_override("font_size", 18)
	best_marker.add_child(marker_label)

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
	_show_status("IGNIÇÃO!", 1.4)

func _on_launch_finished() -> void:
	_show_status("VOCÊ ESTÁ NO CONTROLE", 1.5)

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
	_show_status(boost_name.to_upper(), 1.25)

func _on_highspeed_changed(active: bool) -> void:
	if active:
		_show_status("HIGHSPEED MODE", 2.0)

func _show_status(text: String, duration: float) -> void:
	boost_label.text = text
	boost_label.visible = true
	boost_message_time = duration

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
		if SaveManager.discover_region(current_region):
			_show_status("DESCOBERTO: %s" % current_region, 2.0)

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
	game_over_stats.text = "%d m\n+%d coins\nBest: %d m\n%d regiões estudadas" % [max_altitude, krizo.run_coins, SaveManager.best_altitude(), SaveManager.discovery_count()]
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
	shop_info.text = "COINS: %d • RUNS: %d\nMAPA: %d regiões • %d achievements\n\nTank Lv.%d — %d\nThrust Lv.%d — %d\nControl Lv.%d — %d\nEfficiency Lv.%d — %d" % [
		SaveManager.coins(), SaveManager.runs(), SaveManager.discovery_count(), SaveManager.achievement_count(),
		SaveManager.upgrade_level("tank"), SaveManager.upgrade_cost("tank"),
		SaveManager.upgrade_level("thrust"), SaveManager.upgrade_cost("thrust"),
		SaveManager.upgrade_level("control"), SaveManager.upgrade_cost("control"),
		SaveManager.upgrade_level("efficiency"), SaveManager.upgrade_cost("efficiency")
	]
