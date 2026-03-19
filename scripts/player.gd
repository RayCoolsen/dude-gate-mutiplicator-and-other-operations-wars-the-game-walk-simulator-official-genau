extends CharacterBody3D

signal count_changed(new_count: int)

@export var forward_speed: float = 10.0
@export var side_speed: float = 12.0
@export var side_limit: float = 6.0
@export var count: int = 5

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	randomize()
	_apply_random_color()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_axis("ui_left", "ui_right")

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
	count_changed.emit(count)
	print("Neuer Count:", count)

func _apply_random_color() -> void:
	var material := StandardMaterial3D.new()

	var hue := randf()
	var saturation := randf_range(0.65, 0.95)
	var value_brightness := randf_range(0.75, 1.0)

	material.albedo_color = Color.from_hsv(hue, saturation, value_brightness)
	material.roughness = 0.8

	mesh_instance.material_override = material
