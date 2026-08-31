extends Node2D

@onready var krizo: CharacterBody2D = $World/Krizo
@onready var camera: Camera2D = $Camera2D
@onready var altitude_label: Label = $HUD/Margin/VBox/Altitude
@onready var fuel_bar: ProgressBar = $HUD/Margin/VBox/Fuel
@onready var help_label: Label = $HUD/Help
@onready var game_over: Control = $HUD/GameOver

var best_altitude := 0

func _ready() -> void:
	krizo.altitude_changed.connect(_on_altitude_changed)
	krizo.fuel_changed.connect(_on_fuel_changed)
	krizo.crashed.connect(_on_crashed)
	game_over.visible = false

func _process(delta: float) -> void:
	# Camera only follows upward, giving the classic vertical-climb feel.
	var target_y := min(camera.global_position.y, krizo.global_position.y - 260.0)
	camera.global_position.y = lerp(camera.global_position.y, target_y, 4.0 * delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			Input.action_press("jetpack")
		else:
			Input.action_release("jetpack")

func _on_altitude_changed(meters: int) -> void:
	best_altitude = max(best_altitude, meters)
	altitude_label.text = "%04d m" % meters

func _on_fuel_changed(ratio: float) -> void:
	fuel_bar.value = ratio * 100.0

func _on_crashed() -> void:
	game_over.visible = true
	help_label.visible = false

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()
