extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body is not KrizoPlayer:
		return
	var krizo: KrizoPlayer = body as KrizoPlayer
	var hit_from_below: bool = krizo.velocity.y < 0.0 and krizo.global_position.y > global_position.y + 8.0
	if hit_from_below:
		krizo.bump_head()
	else:
		krizo.crash()
