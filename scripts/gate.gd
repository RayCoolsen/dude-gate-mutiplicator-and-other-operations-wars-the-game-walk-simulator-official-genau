extends Area3D

@export_enum("add", "sub", "mul", "div") var operation: String = "add"
@export var value: int = 10

var used: bool = false

@onready var label_3d: Label3D = $Label3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_update_text()

func _update_text() -> void:
	var prefix := "+"
	match operation:
		"add":
			prefix = "+"
		"sub":
			prefix = "-"
		"mul":
			prefix = "x"
		"div":
			prefix = "/"

	label_3d.text = "%s%d" % [prefix, value]

func _on_body_entered(body: Node) -> void:
	if used:
		return

	if body.has_method("apply_gate"):
		used = true
		body.apply_gate(operation, value)
		collision_shape.disabled = true
		visible = false
