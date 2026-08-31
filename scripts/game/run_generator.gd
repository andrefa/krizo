extends Node2D

@export var obstacle_scene: PackedScene
@export var fuel_scene: PackedScene
@export var coin_scene: PackedScene

var next_chunk_y := 700.0
var generated_until := 0

func prime() -> void:
	for i in GameBalance.PRELOAD_CHUNKS:
		_generate_chunk(i)

func update_for_player(player_y: float, altitude: int) -> void:
	while next_chunk_y > player_y - GameBalance.CHUNK_HEIGHT * GameBalance.PRELOAD_CHUNKS:
		_generate_chunk(generated_until)
	_cleanup(player_y)

func _generate_chunk(index: int) -> void:
	var top_y := 700.0 - float(index + 1) * GameBalance.CHUNK_HEIGHT
	var difficulty := GameBalance.difficulty_for_altitude(int(abs(top_y) / GameBalance.PIXELS_PER_METER))
	var obstacle_count := 2 + int(round(difficulty * 2.0))
	for i in obstacle_count:
		var obstacle := obstacle_scene.instantiate()
		obstacle.position = Vector2(randf_range(175.0, 545.0), top_y + randf_range(80.0, GameBalance.CHUNK_HEIGHT - 60.0))
		obstacle.rotation = randf_range(-0.35, 0.35)
		obstacle.scale.x = randf_range(0.75, 1.25)
		add_child(obstacle)
	if index % 2 == 0:
		var fuel := fuel_scene.instantiate()
		fuel.position = Vector2(randf_range(180.0, 540.0), top_y + randf_range(110.0, 390.0))
		add_child(fuel)
	var coin_count := 3 + randi_range(0, 3)
	var coin_x := randf_range(190.0, 530.0)
	for i in coin_count:
		var coin := coin_scene.instantiate()
		coin.position = Vector2(coin_x + sin(float(i)) * 55.0, top_y + 80.0 + i * 58.0)
		add_child(coin)
	generated_until = index + 1
	next_chunk_y = top_y

func _cleanup(player_y: float) -> void:
	for child in get_children():
		if child is Node2D and child.position.y > player_y + GameBalance.DESPAWN_DISTANCE:
			child.queue_free()
