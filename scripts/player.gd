extends CharacterBody3D

signal count_changed(new_count: int)

@export var forward_speed: float = 10.0
@export var side_speed: float = 12.0
@export var side_limit: float = 6.0
@export var count: int = 5

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
