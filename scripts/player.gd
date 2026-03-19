extends CharacterBody3D

signal count_changed(new_count: int)

@export var forward_speed: float = 10.0
@export var side_speed: float = 12.0
@export var side_limit: float = 6.0
@export var count: int = 5

@export var base_visual_scale: float = 0.55
@export var scale_multiplier_per_stage: float = 1.16

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var current_stage: int = -1
var current_color: Color = Color.WHITE

func _ready() -> void:
	randomize()
	collision_shape.shape = collision_shape.shape.duplicate()
	_update_evolution_visuals()

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
	_update_evolution_visuals()
	count_changed.emit(count)
	print("Neuer Count:", count)

func _update_evolution_visuals() -> void:
	var new_stage: int = _get_stage_from_count(count)

	if new_stage != current_stage:
		current_stage = new_stage
		current_color = _generate_random_color()

	var scale_value: float = _get_scale_for_stage(current_stage)
	_apply_scale(scale_value)
	_apply_color(current_color)

func _get_stage_from_count(value: int) -> int:
	var safe_value: int = value
	if safe_value < 1:
		safe_value = 1

	return int(floor(log(float(safe_value)) / log(2.0)))

func _get_scale_for_stage(stage: int) -> float:
	return base_visual_scale * pow(scale_multiplier_per_stage, stage)

func _apply_scale(scale_value: float) -> void:
	mesh_instance.scale = Vector3.ONE * scale_value
	mesh_instance.position = Vector3(0, scale_value, 0)

	var capsule: CapsuleShape3D = collision_shape.shape as CapsuleShape3D
	if capsule != null:
		capsule.radius = 0.4 * scale_value
		capsule.height = 1.2 * scale_value

	collision_shape.position = Vector3(0, scale_value, 0)

func _apply_color(color: Color) -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	mesh_instance.material_override = material

func _generate_random_color() -> Color:
	var hue: float = randf()
	var saturation: float = randf_range(0.65, 0.95)
	var brightness: float = randf_range(0.75, 1.0)
	return Color.from_hsv(hue, saturation, brightness)
