class_name TreeMap
extends BaseItem

export(PackedScene) var log_scene
var nextTrees = []

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health_bar($HealthBar)
	set_type('tree')
	add_drop(0.9, log_scene, 'log', 2, 5)
	print(get_path())

func time_tick(year_chaged: int, month_change: int, day_changed: int, hour_changed: int):
	apply_health(0.1)
	add_age(day_changed)
	if day_changed > 0 and get_age(UserData.AGE_TYPES.DAY) >= 1:
		UserData.log('add new tree')
	pass


func _on_FlorestArea_body_entered(body):
	if body == self: return
	if not body is BaseItem: return
	if body.get_type() == get_type():
		nextTrees.append(body)
		UserData.log(['Next tree...', body])
