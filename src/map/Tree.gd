class_name TreeMap
extends BaseItem

export(PackedScene) var log_scene
var next_trees = []

const DAY_NEW_TREE: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_health_bar($HealthBar)
	set_type('tree')
	add_drop(0.9, log_scene, 'log', 2, 5)
	print(get_path())

func time_tick(year_chaged: int, month_change: int, day_changed: int, hour_changed: int):
	apply_health(0.1 * hour_changed)
	add_age(hour_changed)
	if get_health() < base_health or next_trees.size() >= 5: return
	
	if day_changed > 0 and get_age(UserData.AGE_TYPES.DAY) >= DAY_NEW_TREE:
		print('add three')
		var world = get_tree().get_current_scene()
		var angle = randf() * 360
		var new_pos = global_position
		new_pos.x += sin(angle) * 20
		new_pos.y += cos(angle) * 20
		world.add_map_object(get_type(), new_pos)
	pass


func _on_FlorestArea_body_entered(body):
	if body == self: return
	if not body is BaseItem: return
	if body.get_type() == get_type():
		next_trees.append(body)
		#UserData.log(['Next tree...', body])


func _on_FlorestArea_body_exited(body):
	if body == self: return
	if not body is BaseItem: return
	if body.get_type() == get_type():
		next_trees.erase(body)
		#UserData.log(['remove tree...', body])
