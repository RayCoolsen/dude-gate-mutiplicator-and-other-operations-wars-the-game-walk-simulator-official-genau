extends Node3D

@export var target_path: NodePath
@export var follow_speed: float = 8.0
@export var offset: Vector3 = Vector3(0, 0, 0)

var target: Node3D

func _ready() -> void:
	if target_path != NodePath():
		target = get_node(target_path) as Node3D

func _process(delta: float) -> void:
	if target == null:
		return

	var desired_position := Vector3(
		target.global_position.x,
		0.0,
		target.global_position.z
	) + offset

	global_position = global_position.lerp(desired_position, min(delta * follow_speed, 1.0))
