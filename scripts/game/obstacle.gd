extends Area2D
class_name ObstacleHazard

var motion_velocity: Vector2 = Vector2.ZERO
var warning_time: float = 0.0
var warning_total: float = 0.0
var activated: bool = true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var rock: Polygon2D = $Rock

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if warning_time > 0.0:
		activated = false
		collision_shape.set_deferred("disabled", true)

func configure_motion(velocity: Vector2, delay: float) -> void:
	motion_velocity = velocity
	warning_time = maxf(0.0, delay)
	warning_total = warning_time

func configure_tint(color: Color) -> void:
	modulate = color

func _process(delta: float) -> void:
	if warning_time > 0.0:
		warning_time = maxf(0.0, warning_time - delta)
		var pulse: float = 0.45 + absf(sin(Time.get_ticks_msec() * 0.018)) * 0.55
		rock.modulate.a = pulse
		if warning_time <= 0.0:
			activated = true
			rock.modulate.a = 1.0
			collision_shape.set_deferred("disabled", false)
		return
	if motion_velocity != Vector2.ZERO:
		position += motion_velocity * delta

func _on_body_entered(body: Node) -> void:
	if activated and body is KrizoPlayer:
		var krizo: KrizoPlayer = body as KrizoPlayer
		krizo.hit_obstacle(global_position)
