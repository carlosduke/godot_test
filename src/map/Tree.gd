extends BaseItem

export(PackedScene) var log_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health_bar($HealthBar)
	set_type('tree')
	add_drop(0.9, log_scene, 'log', 10, 50)
