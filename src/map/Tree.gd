class_name TreeMap
extends BaseItem

export(PackedScene) var log_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health_bar($HealthBar)
	set_type('tree')
	add_drop(0.9, log_scene, 'log', 2, 5)

func time_tick(year_chaged: bool, month_change: bool, day_changed: bool, hour_changed: bool):
	apply_health(0.1)
	pass
