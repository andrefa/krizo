extends Area2D
class_name BoostPickup

@export_enum("gas", "turbo", "nitro", "plasma") var boost_type: String = "gas"
@export var bob_speed: float = 2.2
@export var bob_distance: float = 6.0

var base_y: float = 0.0
var elapsed: float = 0.0

@onready var core: Polygon2D = $Core
@onready var ring: Polygon2D = $Ring

func _ready() -> void:
	base_y = position.y
	body_entered.connect(_on_body_entered)
	_apply_color()

func _process(delta: float) -> void:
	elapsed += delta
	position.y = base_y + sin(elapsed * bob_speed) * bob_distance
	ring.rotation += delta * 1.8

func configure(type: String) -> void:
	boost_type = type
	if is_node_ready():
		_apply_color()

func _apply_color() -> void:
	match boost_type:
		"turbo":
			core.color = Color("ff8a18")
			ring.color = Color("ffd45c")
		"nitro":
			core.color = Color("39a7ff")
			ring.color = Color("a8e7ff")
		"plasma":
			core.color = Color("b45cff")
			ring.color = Color("f2b6ff")
		_:
			core.color = Color("64cf5b")
			ring.color = Color("d5ff83")

func _on_body_entered(body: Node) -> void:
	if body.has_method("apply_boost"):
		body.apply_boost(boost_type)
		queue_free()
