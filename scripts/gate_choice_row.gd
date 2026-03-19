extends Node3D

@export_range(2, 3, 1) var lane_count: int = 2

@export_enum("add", "sub", "mul", "div") var left_operation: String = "add"
@export var left_value: int = 10

@export_enum("add", "sub", "mul", "div") var center_operation: String = "add"
@export var center_value: int = 5

@export_enum("add", "sub", "mul", "div") var right_operation: String = "mul"
@export var right_value: int = 2

@onready var gate_left = $GateLeft
@onready var gate_center = $GateCenter
@onready var gate_right = $GateRight

@onready var divider_a: StaticBody3D = $DividerA
@onready var divider_b: StaticBody3D = $DividerB

func _ready() -> void:
	_apply_layout()

func _apply_layout() -> void:
	if lane_count == 2:
		_setup_two_lanes()
	else:
		_setup_three_lanes()

func _setup_two_lanes() -> void:
	gate_left.position = Vector3(-3.0, 0, 0)
	gate_right.position = Vector3(3.0, 0, 0)
	gate_center.position = Vector3(0, 0, 0)

	gate_left.scale = Vector3(1.85, 1.0, 1.0)
	gate_right.scale = Vector3(1.85, 1.0, 1.0)
	gate_center.scale = Vector3(1.0, 1.0, 1.0)

	gate_left.set_gate_data(left_operation, left_value)
	gate_right.set_gate_data(right_operation, right_value)

	gate_left.set_gate_enabled(true)
	gate_right.set_gate_enabled(true)
	gate_center.set_gate_enabled(false)

	_set_divider(divider_a, true, 0.0)
	_set_divider(divider_b, false, 0.0)

func _setup_three_lanes() -> void:
	gate_left.position = Vector3(-4.0, 0, 0)
	gate_center.position = Vector3(0, 0, 0)
	gate_right.position = Vector3(4.0, 0, 0)

	gate_left.scale = Vector3(1.2, 1.0, 1.0)
	gate_center.scale = Vector3(1.2, 1.0, 1.0)
	gate_right.scale = Vector3(1.2, 1.0, 1.0)

	gate_left.set_gate_data(left_operation, left_value)
	gate_center.set_gate_data(center_operation, center_value)
	gate_right.set_gate_data(right_operation, right_value)

	gate_left.set_gate_enabled(true)
	gate_center.set_gate_enabled(true)
	gate_right.set_gate_enabled(true)

	_set_divider(divider_a, true, -2.0)
	_set_divider(divider_b, true, 2.0)

func _set_divider(divider: StaticBody3D, enabled: bool, x_pos: float) -> void:
	divider.position = Vector3(x_pos, 2.0, 0)

	var collision_shape := divider.get_node("CollisionShape3D") as CollisionShape3D
	var mesh_instance := divider.get_node("MeshInstance3D") as MeshInstance3D

	collision_shape.disabled = not enabled
	mesh_instance.visible = enabled
