extends CharacterBody2D
class_name KrizoPlayer

signal altitude_changed(meters: int)
signal fuel_changed(ratio: float)
signal crashed
signal coin_collected(total_this_run: int)

var gravity: float = GameBalance.BASE_GRAVITY
var thrust: float = GameBalance.BASE_THRUST
var horizontal_speed: float = GameBalance.BASE_HORIZONTAL_SPEED
var fuel_capacity: float = GameBalance.BASE_FUEL_CAPACITY
var fuel_burn_per_second: float = GameBalance.BASE_BURN_RATE
var fuel_recharge_per_second: float = GameBalance.BASE_RECHARGE_RATE
var max_fall_speed: float = 720.0
var horizontal_acceleration: float = 1150.0

var fuel: float = 0.0
var start_y: float = 0.0
var alive: bool = true
var run_coins: int = 0
var touch_active: bool = false
var touch_x: float = 360.0

@onready var body: Polygon2D = $Visual/Body
@onready var flame: Polygon2D = $Visual/Flame
@onready var visual: Node2D = $Visual

func _ready() -> void:
	start_y = global_position.y
	_apply_upgrades()
	fuel = fuel_capacity
	fuel_changed.emit(1.0)

func _apply_upgrades() -> void:
	fuel_capacity = GameBalance.fuel_capacity()
	thrust = GameBalance.thrust()
	horizontal_speed = GameBalance.horizontal_speed()
	fuel_burn_per_second = GameBalance.burn_rate()

func _physics_process(delta: float) -> void:
	if not alive:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
		visual.rotation = lerpf(visual.rotation, 0.55, 2.0 * delta)
		move_and_slide()
		return

	var horizontal: float = Input.get_axis("move_left", "move_right")
	if touch_active:
		var horizontal_error: float = touch_x - global_position.x
		horizontal = clampf(horizontal_error / 130.0, -1.0, 1.0)
	velocity.x = move_toward(velocity.x, horizontal * horizontal_speed, horizontal_acceleration * delta)

	var boosting: bool = (Input.is_action_pressed("jetpack") or touch_active) and fuel > 0.0
	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	if boosting:
		velocity.y -= thrust * delta
		fuel = maxf(0.0, fuel - fuel_burn_per_second * delta)
	else:
		fuel = minf(fuel_capacity, fuel + fuel_recharge_per_second * delta)

	_update_visuals(boosting, delta)
	move_and_slide()
	global_position.x = clampf(global_position.x, GameBalance.WORLD_LEFT, GameBalance.WORLD_RIGHT)

	var meters: int = current_altitude()
	altitude_changed.emit(meters)
	fuel_changed.emit(fuel / fuel_capacity)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		touch_active = touch_event.pressed
		touch_x = touch_event.position.x
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		touch_active = true
		touch_x = drag_event.position.x

func _update_visuals(boosting: bool, delta: float) -> void:
	flame.visible = boosting
	if boosting:
		flame.scale.y = 0.85 + randf() * 0.35
	var lean: float = clampf(velocity.x / maxf(horizontal_speed, 1.0), -1.0, 1.0) * 0.22
	visual.rotation = lerpf(visual.rotation, lean, 8.0 * delta)
	var target_scale: Vector2 = Vector2(0.97, 1.05) if boosting else Vector2.ONE
	visual.scale = visual.scale.lerp(target_scale, 10.0 * delta)

func current_altitude() -> int:
	return maxi(0, int((start_y - global_position.y) / GameBalance.PIXELS_PER_METER))

func crash() -> void:
	if not alive:
		return
	alive = false
	body.color = Color("8a3d32")
	flame.visible = false
	velocity.y = maxf(velocity.y, 120.0)
	crashed.emit()

func refuel(amount: float) -> void:
	if not alive:
		return
	fuel = minf(fuel_capacity, fuel + amount)
	fuel_changed.emit(fuel / fuel_capacity)

func collect_coin(amount: int = 1) -> void:
	if not alive:
		return
	run_coins += amount
	coin_collected.emit(run_coins)
