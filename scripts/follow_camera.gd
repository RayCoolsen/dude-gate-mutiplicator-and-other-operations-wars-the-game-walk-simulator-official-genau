extends Node3D

@export var target_path: NodePath
@export var follow_speed: float = 6.0
@export var offset: Vector3 = Vector3(0, 6, -10)

var target: Node3D

func _ready() -> void:
	if target_path != NodePath():
		target = get_node(target_path) as Node3D

func _process(delta: float) -> void:
	if target == null:
		return

	var desired_position := target.global_position + offset
	global_position = global_position.lerp(desired_position, delta * follow_speed)
	look_at(target.global_position + Vector3(0, 1.5, 0), Vector3.UP)
