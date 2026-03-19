extends Area3D

@export_enum("add", "sub", "mul", "div") var operation: String = "add"
@export var value: int = 10

var used: bool = false

@onready var label_3d: Label3D = $Label3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var left_post: MeshInstance3D = $LeftPost
@onready var right_post: MeshInstance3D = $RightPost
@onready var top_bar: MeshInstance3D = $TopBar
@onready var sign_board: MeshInstance3D = $SignBoard

func _ready() -> void:
	_prepare_label()
	body_entered.connect(_on_body_entered)
	_update_visuals()

func _prepare_label() -> void:
	label_3d.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label_3d.position = Vector3(0, 2.55, 0.48)
	label_3d.font_size = 120

func set_gate_data(new_operation: String, new_value: int) -> void:
	operation = new_operation
	value = new_value
	_update_visuals()

func set_gate_enabled(enabled: bool) -> void:
	used = false
	visible = enabled
	monitoring = enabled
	monitorable = enabled
	collision_shape.disabled = not enabled

func _update_visuals() -> void:
	var prefix := "+"
	var gate_color := Color(0.2, 0.9, 0.35, 1.0)

	match operation:
		"add":
			prefix = "+"
			gate_color = Color(0.2, 0.9, 0.35, 1.0)
		"sub":
			prefix = "-"
			gate_color = Color(0.95, 0.3, 0.3, 1.0)
		"mul":
			prefix = "x"
			gate_color = Color(0.25, 0.55, 1.0, 1.0)
		"div":
			prefix = "/"
			gate_color = Color(1.0, 0.7, 0.2, 1.0)

	label_3d.text = "%s%d" % [prefix, value]

	_apply_color(left_post, gate_color)
	_apply_color(right_post, gate_color)
	_apply_color(top_bar, gate_color)

func _apply_color(mesh_instance: MeshInstance3D, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	mesh_instance.material_override = material

func _on_body_entered(body: Node) -> void:
	if used:
		return

	if body.has_method("apply_gate"):
		used = true
		body.apply_gate(operation, value)
		collision_shape.disabled = true
		visible = false
