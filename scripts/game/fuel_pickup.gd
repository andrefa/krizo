extends Area2D

@export var fuel_amount := 2.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_method("refuel"):
		body.refuel(fuel_amount)
		queue_free()
