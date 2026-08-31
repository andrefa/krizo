extends CharacterBody2D
class_name KrizoPlayer

signal altitude_changed(meters: int)
signal fuel_changed(ratio: float)
signal crashed
signal coin_collected(total_this_run: int)
signal boost_activated(boost_name: String)
signal highspeed_changed(active: bool)
signal launch_finished

const BASE_VISUAL_SCALE := Vector2(1.25, 1.25)
const LAUNCH_DURATION := 1.55
const LAUNCH_SPEED := -760.0

var gravity: float = GameBalance.BASE_GRAVITY
var thrust: float = GameBalance.BASE_THRUST
var horizontal_speed: float = GameBalance.BASE_HORIZONTAL_SPEED
var fuel_capacity: float = GameBalance.BASE_FUEL_CAPACITY
var fuel_burn_per_second: float = GameBalance.BASE_BURN_RATE
var fuel_recharge_per_second: float = GameBalance.BASE_RECHARGE_RATE
var max_fall_speed: float = 720.0
var horizontal_acceleration: float = 1500.0

var fuel: float = 0.0
var start_y: float = 0.0
var alive: bool = true
var run_coins: int = 0
var touch_active: bool = false
var touch_x: float = 360.0
var mouse_active: bool = false
var mouse_x: float = 360.0
var launch_time_left: float = 0.0
var highspeed_time_left: float = 0.0
var highspeed_velocity: float = -1120.0
var impact_cooldown: float = 0.0

@onready var body: Polygon2D = $Visual/Body
@onready var flame: Polygon2D = $Visual/Flame
@onready var visual: Node2D = $Visual

func _ready() -> void:
	start_y = global_position.y
	_apply_upgrades()
	fuel = fuel_capacity
	visual.scale = BASE_VISUAL_SCALE
	fuel_changed.emit(1.0)

func _apply_upgrades() -> void:
	fuel_capacity = GameBalance.fuel_capacity()
	thrust = GameBalance.thrust()
	horizontal_speed = GameBalance.horizontal_speed()
	fuel_burn_per_second = GameBalance.burn_rate()

func begin_launch() -> void:
	launch_time_left = LAUNCH_DURATION
	velocity = Vector2(0.0, LAUNCH_SPEED)

func _physics_process(delta: float) -> void:
	impact_cooldown = maxf(0.0, impact_cooldown - delta)
	if not alive:
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		velocity.x = move_toward(velocity.x, 0.0, 350.0 * delta)
		visual.rotation = lerpf(visual.rotation, 0.55, 2.0 * delta)
		move_and_slide()
		return

	if launch_time_left > 0.0:
		_process_launch(delta)
		return

	if highspeed_time_left > 0.0:
		_process_highspeed(delta)
		return

	_process_normal_flight(delta)

func _process_launch(delta: float) -> void:
	launch_time_left = maxf(0.0, launch_time_left - delta)
	velocity.x = move_toward(velocity.x, 0.0, 1800.0 * delta)
	velocity.y = move_toward(velocity.y, LAUNCH_SPEED, 1800.0 * delta)
	_update_visuals(true, delta)
	move_and_slide()
	_emit_run_state()
	if launch_time_left <= 0.0:
		launch_finished.emit()

func _process_normal_flight(delta: float) -> void:
	var horizontal: float = _desired_horizontal_input()
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
	_emit_run_state()

func _process_highspeed(delta: float) -> void:
	highspeed_time_left = maxf(0.0, highspeed_time_left - delta)
	var horizontal: float = _desired_horizontal_input()
	var delayed_acceleration: float = horizontal_acceleration * 0.48
	velocity.x = move_toward(velocity.x, horizontal * horizontal_speed * 1.35, delayed_acceleration * delta)
	velocity.y = move_toward(velocity.y, highspeed_velocity, 950.0 * delta)
	fuel = minf(fuel_capacity, fuel + fuel_recharge_per_second * 0.5 * delta)
	_update_visuals(true, delta)
	move_and_slide()
	_emit_run_state()
	if highspeed_time_left <= 0.0:
		highspeed_changed.emit(false)

func _desired_horizontal_input() -> float:
	var horizontal: float = Input.get_axis("move_left", "move_right")
	var pointer_active: bool = touch_active or mouse_active
	if pointer_active:
		var target_x: float = _pointer_world_x()
		var horizontal_error: float = target_x - global_position.x
		horizontal = clampf(horizontal_error / 105.0, -1.0, 1.0)
	return horizontal

func _pointer_world_x() -> float:
	var screen_x: float = touch_x if touch_active else mouse_x
	var canvas_inverse: Transform2D = get_viewport().get_canvas_transform().affine_inverse()
	return (canvas_inverse * Vector2(screen_x, 0.0)).x

func _emit_run_state() -> void:
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
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			mouse_active = mouse_button.pressed
			mouse_x = mouse_button.position.x
	elif event is InputEventMouseMotion and mouse_active:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		mouse_x = mouse_motion.position.x

func _update_visuals(boosting: bool, delta: float) -> void:
	flame.visible = boosting
	if boosting:
		var flame_bonus: float = 1.45 if highspeed_time_left > 0.0 else 1.0
		flame.scale.y = (0.85 + randf() * 0.35) * flame_bonus
	var lean: float = clampf(velocity.x / maxf(horizontal_speed, 1.0), -1.0, 1.0) * 0.22
	visual.rotation = lerpf(visual.rotation, lean, 8.0 * delta)
	var squash: Vector2 = Vector2(0.97, 1.05) if boosting else Vector2.ONE
	var target_scale: Vector2 = BASE_VISUAL_SCALE * squash
	visual.scale = visual.scale.lerp(target_scale, 10.0 * delta)

func current_altitude() -> int:
	return maxi(0, int((start_y - global_position.y) / GameBalance.PIXELS_PER_METER))

func hit_obstacle(obstacle_position: Vector2) -> void:
	if not alive or impact_cooldown > 0.0:
		return
	impact_cooldown = 0.28
	var away: float = signf(global_position.x - obstacle_position.x)
	if is_zero_approx(away):
		away = 1.0
	velocity.x += away * 220.0
	velocity.y = maxf(velocity.y, 180.0)
	fuel = maxf(0.0, fuel - 0.2)
	fuel_changed.emit(fuel / fuel_capacity)

func bump_head() -> void:
	hit_obstacle(global_position + Vector2(0.0, -50.0))

func apply_boost(boost_type: String) -> void:
	if not alive:
		return
	match boost_type:
		"turbo":
			velocity.y = minf(velocity.y, -980.0)
			fuel = minf(fuel_capacity, fuel + 0.8)
		"nitro":
			_start_highspeed(2.8, -1180.0)
		"plasma":
			_start_highspeed(5.2, -1480.0)
		_:
			velocity.y = minf(velocity.y, -720.0)
			fuel = minf(fuel_capacity, fuel + 0.4)
	boost_activated.emit(boost_type)
	fuel_changed.emit(fuel / fuel_capacity)

func _start_highspeed(duration: float, speed: float) -> void:
	var was_active: bool = highspeed_time_left > 0.0
	highspeed_time_left = maxf(highspeed_time_left, duration)
	highspeed_velocity = speed
	velocity.y = minf(velocity.y, speed)
	if not was_active:
		highspeed_changed.emit(true)

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
