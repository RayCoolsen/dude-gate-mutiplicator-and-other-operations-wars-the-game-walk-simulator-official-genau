extends Node3D

const GATE_ROW_SCENE: PackedScene = preload("res://scenes/gate_choice_row.tscn")

@export var initial_rows: int = 6
@export var first_row_z: float = -50.0
@export var row_spacing: float = 45.0
@export var spawn_ahead_distance: float = 260.0
@export var cleanup_behind_distance: float = 30.0

@onready var gate_rows: Node3D = $GateRows

var player: Node3D = null
var next_row_z: float = 0.0
var spawned_row_count: int = 0

func _ready() -> void:
	randomize()

	if has_node("../Player"):
		player = get_node("../Player") as Node3D

	next_row_z = first_row_z

	for _row_index in range(initial_rows):
		_spawn_next_row()

func _process(_delta: float) -> void:
	if player == null:
		if has_node("../Player"):
			player = get_node("../Player") as Node3D
		else:
			return

	while next_row_z > player.global_position.z - spawn_ahead_distance:
		_spawn_next_row()

	_cleanup_old_rows()

func _spawn_next_row() -> void:
	var lane_count: int = _pick_lane_count(spawned_row_count)

	var left_operation: String = _pick_operation(spawned_row_count)
	var center_operation: String = _pick_operation(spawned_row_count)
	var right_operation: String = _pick_operation(spawned_row_count)

	while center_operation == left_operation:
		center_operation = _pick_operation(spawned_row_count)

	while right_operation == left_operation or right_operation == center_operation:
		right_operation = _pick_operation(spawned_row_count)

	var left_value: int = _pick_value_for_operation(left_operation, spawned_row_count)
	var center_value: int = _pick_value_for_operation(center_operation, spawned_row_count)
	var right_value: int = _pick_value_for_operation(right_operation, spawned_row_count)

	var row_node: Node = GATE_ROW_SCENE.instantiate()
	row_node.set("lane_count", lane_count)
	row_node.set("left_operation", left_operation)
	row_node.set("left_value", left_value)
	row_node.set("center_operation", center_operation)
	row_node.set("center_value", center_value)
	row_node.set("right_operation", right_operation)
	row_node.set("right_value", right_value)

	var row_3d: Node3D = row_node as Node3D
	if row_3d != null:
		row_3d.position = Vector3(0, 0, next_row_z)

	gate_rows.add_child(row_node)

	next_row_z -= row_spacing
	spawned_row_count += 1

func _cleanup_old_rows() -> void:
	if player == null:
		return

	var child_index: int = gate_rows.get_child_count() - 1
	while child_index >= 0:
		var row_node: Node3D = gate_rows.get_child(child_index) as Node3D
		if row_node != null and row_node.global_position.z > player.global_position.z + cleanup_behind_distance:
			row_node.queue_free()

		child_index -= 1

func _pick_lane_count(row_index: int) -> int:
	if row_index == 0:
		return 2

	if randf() < 0.55:
		return 2

	return 3

func _pick_operation(row_index: int) -> String:
	var roll: int = randi_range(0, 99)

	if row_index < 2:
		if roll < 50:
			return "add"
		elif roll < 80:
			return "mul"
		elif roll < 95:
			return "sub"
		else:
			return "div"

	if roll < 38:
		return "add"
	elif roll < 63:
		return "mul"
	elif roll < 85:
		return "sub"
	else:
		return "div"

func _pick_value_for_operation(operation: String, row_index: int) -> int:
	var difficulty_tier: int = row_index / 3
	if difficulty_tier > 6:
		difficulty_tier = 6

	match operation:
		"add":
			var add_values: Array[int] = [4, 6, 8, 10, 12, 15]
			var add_index: int = randi_range(0, add_values.size() - 1)
			return add_values[add_index] + difficulty_tier * 2

		"sub":
			var sub_values: Array[int] = [2, 3, 4, 5, 6]
			var sub_index: int = randi_range(0, sub_values.size() - 1)
			var sub_bonus: int = difficulty_tier
			if sub_bonus > 3:
				sub_bonus = 3
			return sub_values[sub_index] + sub_bonus

		"mul":
			if difficulty_tier >= 4 and randf() < 0.45:
				return 3
			return 2

		"div":
			if difficulty_tier >= 4 and randf() < 0.35:
				return 3
			return 2

	return 1
