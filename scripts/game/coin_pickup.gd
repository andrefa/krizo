extends Area2D

@export var amount := 1
@export var spin_speed := 2.8
var base_y := 0.0
var time := 0.0

func _ready() -> void:
	base_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time += delta
	rotation += spin_speed * delta
	position.y = base_y + sin(time * 3.0) * 5.0

func _on_body_entered(body: Node) -> void:
	if body.has_method("collect_coin"):
		body.collect_coin(amount)
		queue_free()
