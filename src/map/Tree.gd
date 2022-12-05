extends BaseItem

export(PackedScene) var log_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	add_drop(0.9, log_scene, 1, 5)
