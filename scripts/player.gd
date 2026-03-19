extends CharacterBody3D

@export var forward_speed: float = 10.0
@export var side_speed: float = 12.0
@export var side_limit: float = 6.0

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
