extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is KrizoPlayer:
		var krizo: KrizoPlayer = body as KrizoPlayer
		krizo.hit_obstacle(global_position)
