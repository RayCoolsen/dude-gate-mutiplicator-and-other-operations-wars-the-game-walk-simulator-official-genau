extends Node3D

@onready var player = $Player
@onready var count_label: Label = $CanvasLayer/CountLabel

func _ready() -> void:
	update_count_label(player.count)
	player.count_changed.connect(update_count_label)

func update_count_label(new_count: int) -> void:
	count_label.text = "Count: %d" % new_count
