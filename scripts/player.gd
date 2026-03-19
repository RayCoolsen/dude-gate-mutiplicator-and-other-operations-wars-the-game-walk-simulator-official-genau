extends CharacterBody3D

@export var forward_speed: float = 8.0
@export var side_speed: float = 10.0
@export var side_limit: float = 3.5

func _physics_process(delta: float) -> void:
	var input_dir := 0.0

	if Input.is_action_pressed("ui_left"):
		input_dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		input_dir += 1.0

	velocity.x = input_dir * side_speed
	velocity.z = forward_speed

	move_and_slide()

	position.x = clamp(position.x, -side_limit, side_limit)
