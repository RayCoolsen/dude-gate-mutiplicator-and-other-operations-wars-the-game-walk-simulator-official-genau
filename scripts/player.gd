extends CharacterBody3D

signal count_changed(new_count: int)

const CROWD_DUDE_SCENE: PackedScene = preload("res://scenes/crowd_dude.tscn")

@export var forward_speed: float = 10.0
@export var side_speed: float = 12.0
@export var side_limit: float = 6.0
@export var count: int = 5

@export var base_visual_scale: float = 0.38
@export var scale_growth_strength: float = 0.42

@export var crowd_columns: int = 3
@export var crowd_x_spacing: float = 1.5
@export var crowd_z_spacing: float = 1.8
@export var crowd_start_z: float = 2.4

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var crowd_root: Node3D = $CrowdRoot

var current_stage: int = -1
var current_color: Color = Color.WHITE

func _ready() -> void:
	randomize()
	collision_shape.shape = collision_shape.shape.duplicate()
	_update_visuals()

func _physics_process(delta: float) -> void:
	var input_dir: float = Input.get_axis("ui_left", "ui_right")

	velocity.x = input_dir * side_speed
	velocity.z = -forward_speed

	move_and_slide()

	if global_position.x < -side_limit:
		global_position.x = -side_limit
		velocity.x = 0.0
	elif global_position.x > side_limit:
		global_position.x = side_limit
		velocity.x = 0.0

func apply_gate(operation: String, value: int) -> void:
	match operation:
		"add":
			count += value
		"sub":
			count -= value
		"mul":
			count *= value
		"div":
			if value != 0:
				count = int(count / value)

	count = max(count, 0)
	_update_visuals()
	count_changed.emit(count)
	print("Neuer Count:", count)

func _update_visuals() -> void:
	if count <= 0:
		mesh_instance.visible = false
		_clear_crowd()
		return

	mesh_instance.visible = true

	var main_bit_value: int = _get_highest_bit_value(count)
	var new_stage: int = _get_stage_from_bit_value(main_bit_value)

	if new_stage != current_stage:
		current_stage = new_stage
		current_color = _generate_random_color()

	var main_scale: float = _get_scale_for_stage(current_stage)
	_apply_main_scale(main_scale)
	_apply_material_to_mesh(mesh_instance, current_color)

	_rebuild_crowd(main_bit_value)

func _apply_main_scale(scale_value: float) -> void:
	mesh_instance.scale = Vector3.ONE * scale_value
	mesh_instance.position = Vector3(0, scale_value, 0)

	var capsule: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	if capsule != null:
		capsule.radius = 0.4 * scale_value
		capsule.height = 1.2 * scale_value

	collision_shape.position = Vector3(0, scale_value, 0)

func _rebuild_crowd(main_bit_value: int) -> void:
	_clear_crowd()

	var bit_values: Array[int] = _get_set_bit_values(count)
	var follower_values: Array[int] = []

	var main_removed: bool = false

	for bit_index in range(bit_values.size()):
		var bit_value: int = bit_values[bit_index]

		if bit_value == main_bit_value and not main_removed:
			main_removed = true
		else:
			follower_values.append(bit_value)

	for follower_index in range(follower_values.size()):
		var follower_bit_value: int = follower_values[follower_index]
		var follower_stage: int = _get_stage_from_bit_value(follower_bit_value)
		var follower_scale: float = _get_scale_for_stage(follower_stage)

		var crowd_dude: Node3D = CROWD_DUDE_SCENE.instantiate() as Node3D
		crowd_root.add_child(crowd_dude)

		crowd_dude.position = _get_crowd_slot_position(follower_index, follower_values.size())
		crowd_dude.scale = Vector3.ONE * follower_scale

		var follower_mesh: MeshInstance3D = crowd_dude.get_node("MeshInstance3D") as MeshInstance3D
		if follower_mesh != null:
			_apply_material_to_mesh(follower_mesh, current_color)


func _get_crowd_slot_position(index: int, total: int) -> Vector3:
	var columns: int = crowd_columns
	if columns < 1:
		columns = 1

	var row: int = index / columns
	var column_index: int = index % columns

	var remaining: int = total - row * columns
	var items_in_row: int = columns
	if remaining < columns:
		items_in_row = remaining

	var row_center: float = (float(items_in_row) - 1.0) * 0.5
	var x: float = (float(column_index) - row_center) * crowd_x_spacing
	var z: float = crowd_start_z + float(row) * crowd_z_spacing

	return Vector3(x, 0, z)

func _clear_crowd() -> void:
	var child_index: int = crowd_root.get_child_count() - 1
	while child_index >= 0:
		var child: Node = crowd_root.get_child(child_index)
		child.queue_free()
		child_index -= 1

func _get_set_bit_values(value: int) -> Array[int]:
	var result: Array[int] = []

	if value <= 0:
		return result

	var working_value: int = value
	var bit_value: int = 1

	while working_value > 0:
		if (working_value & 1) == 1:
			result.push_front(bit_value)

		working_value = working_value >> 1
		bit_value = bit_value << 1

	return result

func _get_highest_bit_value(value: int) -> int:
	if value <= 1:
		return 1

	var bit_value: int = 1
	while (bit_value << 1) <= value:
		bit_value = bit_value << 1

	return bit_value

func _get_stage_from_bit_value(bit_value: int) -> int:
	var safe_value: int = bit_value
	if safe_value < 1:
		safe_value = 1

	var stage: int = 0
	while safe_value > 1:
		safe_value = safe_value >> 1
		stage += 1

	return stage

func _get_scale_for_stage(stage: int) -> float:
	return base_visual_scale + scale_growth_strength * (sqrt(float(stage) + 1.0) - 1.0)

func _apply_material_to_mesh(target_mesh: MeshInstance3D, color: Color) -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	target_mesh.material_override = material

func _generate_random_color() -> Color:
	var hue: float = randf()
	var saturation: float = randf_range(0.65, 0.95)
	var brightness: float = randf_range(0.75, 1.0)
	return Color.from_hsv(hue, saturation, brightness)
