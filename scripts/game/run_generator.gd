extends Node2D
class_name RunGenerator

@export var obstacle_scene: PackedScene
@export var fuel_scene: PackedScene
@export var coin_scene: PackedScene

var next_chunk_y: float = 700.0
var generated_until: int = 0

func prime() -> void:
	for i: int in range(GameBalance.PRELOAD_CHUNKS):
		_generate_chunk(i)

func update_for_player(player_y: float, _altitude: int) -> void:
	while next_chunk_y > player_y - GameBalance.CHUNK_HEIGHT * float(GameBalance.PRELOAD_CHUNKS):
		_generate_chunk(generated_until)
	_cleanup(player_y)

func _generate_chunk(index: int) -> void:
	var top_y: float = 700.0 - float(index + 1) * GameBalance.CHUNK_HEIGHT
	var difficulty: float = GameBalance.difficulty_for_altitude(int(absf(top_y) / GameBalance.PIXELS_PER_METER))
	var obstacle_count: int = 2 + int(roundf(difficulty * 2.0))
	for _i: int in range(obstacle_count):
		var obstacle: Node2D = obstacle_scene.instantiate() as Node2D
		if obstacle == null:
			continue
		obstacle.position = Vector2(randf_range(175.0, 545.0), top_y + randf_range(80.0, GameBalance.CHUNK_HEIGHT - 60.0))
		obstacle.rotation = randf_range(-0.35, 0.35)
		obstacle.scale.x = randf_range(0.75, 1.25)
		add_child(obstacle)
	if index % 2 == 0:
		var fuel: Node2D = fuel_scene.instantiate() as Node2D
		if fuel != null:
			fuel.position = Vector2(randf_range(180.0, 540.0), top_y + randf_range(110.0, 390.0))
			add_child(fuel)
	var coin_count: int = 3 + randi_range(0, 3)
	var coin_x: float = randf_range(190.0, 530.0)
	for i: int in range(coin_count):
		var coin: Node2D = coin_scene.instantiate() as Node2D
		if coin == null:
			continue
		coin.position = Vector2(coin_x + sin(float(i)) * 55.0, top_y + 80.0 + float(i) * 58.0)
		add_child(coin)
	generated_until = index + 1
	next_chunk_y = top_y

func _cleanup(player_y: float) -> void:
	for child: Node in get_children():
		if child is Node2D:
			var child_2d: Node2D = child as Node2D
			if child_2d.position.y > player_y + GameBalance.DESPAWN_DISTANCE:
				child_2d.queue_free()
