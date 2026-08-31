extends CharacterBody2D

signal altitude_changed(meters: int)
signal fuel_changed(ratio: float)
signal crashed

@export var gravity := 900.0
@export var thrust := 1500.0
@export var max_fall_speed := 700.0
@export var horizontal_speed := 260.0
@export var fuel_capacity := 5.0
@export var fuel_burn_per_second := 1.0
@export var fuel_recharge_per_second := 0.25

var fuel := fuel_capacity
var start_y := 0.0
var alive := true

@onready var body: Polygon2D = $Visual/Body
@onready var flame: Polygon2D = $Visual/Flame
@onready var visual: Node2D = $Visual

func _ready() -> void:
	start_y = global_position.y
	fuel = fuel_capacity
	fuel_changed.emit(1.0)

func _physics_process(delta: float) -> void:
	if not alive:
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
		move_and_slide()
		return

	var horizontal := Input.get_axis("move_left", "move_right")
	velocity.x = move_toward(velocity.x, horizontal * horizontal_speed, 1000.0 * delta)

	var boosting := Input.is_action_pressed("jetpack") and fuel > 0.0
	if boosting:
		velocity.y -= thrust * delta
		fuel = max(0.0, fuel - fuel_burn_per_second * delta)
	else:
		velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
		fuel = min(fuel_capacity, fuel + fuel_recharge_per_second * delta)

	flame.visible = boosting
	visual.rotation = lerp(visual.rotation, clamp(velocity.x / horizontal_speed, -1.0, 1.0) * 0.18, 8.0 * delta)
	visual.scale = Vector2.ONE * (1.03 if boosting else 1.0)

	move_and_slide()
	global_position.x = clamp(global_position.x, 90.0, 630.0)

	var meters := max(0, int((start_y - global_position.y) / 20.0))
	altitude_changed.emit(meters)
	fuel_changed.emit(fuel / fuel_capacity)

func crash() -> void:
	if not alive:
		return
	alive = false
	body.color = Color("8a3d32")
	flame.visible = false
	crashed.emit()

func refuel(amount: float) -> void:
	fuel = min(fuel_capacity, fuel + amount)
