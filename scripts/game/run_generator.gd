extends Node2D
class_name RunGenerator

@export var obstacle_scene: PackedScene
@export var fuel_scene: PackedScene
@export var coin_scene: PackedScene
@export var boost_scene: PackedScene

var next_chunk_y: float = 700.0
var generated_until: int = 0
var generation_center_x: float = 360.0

func prime() -> void:
	for i: int in range(GameBalance.PRELOAD_CHUNKS):
		_generate_chunk(i)

func update_for_player(player_position: Vector2, _altitude: int) -> void:
	generation_center_x = player_position.x
	while next_chunk_y > player_position.y - GameBalance.CHUNK_HEIGHT * float(GameBalance.PRELOAD_CHUNKS):
		_generate_chunk(generated_until)
	_cleanup(player_position)

func _generate_chunk(index: int) -> void:
	var top_y: float = 700.0 - float(index + 1) * GameBalance.CHUNK_HEIGHT
	var altitude_m: int = int(absf(top_y) / GameBalance.PIXELS_PER_METER)
	var difficulty: float = GameBalance.difficulty_for_altitude(altitude_m)
	var center_x: float = generation_center_x

	# The first meters are the launch corridor described in the original GDD.
	if index >= 2:
		var obstacle_count: int = 2 + int(roundf(difficulty * 3.0))
		for _i: int in range(obstacle_count):
			var obstacle: Node2D = obstacle_scene.instantiate() as Node2D
			if obstacle == null:
				continue
			obstacle.position = Vector2(center_x + randf_range(-255.0, 255.0), top_y + randf_range(80.0, GameBalance.CHUNK_HEIGHT - 60.0))
			obstacle.rotation = randf_range(-0.45, 0.45)
			obstacle.scale = Vector2(randf_range(0.75, 1.35), randf_range(0.85, 1.2))
			add_child(obstacle)

	if index % 2 == 0:
		_spawn_fuel(center_x, top_y)

	_spawn_coin_trail(center_x, top_y)

	# GDD rarity order: Gas > Turbo > Nitro > Plasma.
	if index >= 2 and randf() < 0.42:
		_spawn_boost(center_x, top_y, difficulty)

	generated_until = index + 1
	next_chunk_y = top_y

func _spawn_fuel(center_x: float, top_y: float) -> void:
	var fuel: Node2D = fuel_scene.instantiate() as Node2D
	if fuel != null:
		fuel.position = Vector2(center_x + randf_range(-210.0, 210.0), top_y + randf_range(110.0, 390.0))
		add_child(fuel)

func _spawn_coin_trail(center_x: float, top_y: float) -> void:
	var coin_count: int = 3 + randi_range(0, 4)
	var coin_x: float = center_x + randf_range(-180.0, 180.0)
	for i: int in range(coin_count):
		var coin: Node2D = coin_scene.instantiate() as Node2D
		if coin == null:
			continue
		coin.position = Vector2(coin_x + sin(float(i) * 0.8) * 62.0, top_y + 70.0 + float(i) * 58.0)
		add_child(coin)

func _spawn_boost(center_x: float, top_y: float, difficulty: float) -> void:
	if boost_scene == null:
		return
	var boost: BoostPickup = boost_scene.instantiate() as BoostPickup
	if boost == null:
		return
	var roll: float = randf()
	var boost_type: String = "gas"
	if roll > 0.94 - difficulty * 0.05:
		boost_type = "plasma"
	elif roll > 0.80 - difficulty * 0.04:
		boost_type = "nitro"
	elif roll > 0.52:
		boost_type = "turbo"
	boost.configure(boost_type)
	boost.position = Vector2(center_x + randf_range(-205.0, 205.0), top_y + randf_range(100.0, 400.0))
	add_child(boost)

func _cleanup(player_position: Vector2) -> void:
	for child: Node in get_children():
		if child is Node2D:
			var child_2d: Node2D = child as Node2D
			var too_low: bool = child_2d.position.y > player_position.y + GameBalance.DESPAWN_DISTANCE
			var too_far_sideways: bool = absf(child_2d.position.x - player_position.x) > 1800.0
			if too_low or too_far_sideways:
				child_2d.queue_free()
