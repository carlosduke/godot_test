class_name BaseItem
extends StaticBody2D

export(float) var base_health = 10.0
var health
var drop_items = []

func get_health():
	return health

func set_health(_health):
	health = _health

func add_drop(chance: float, scene: PackedScene, _min: int, _max: int):
	drop_items.append({
		'chance': chance,
		'scene': scene,
		'min': _min,
		'max': _max
	})

func _ready():
	health = base_health

func apply_damage(damage: float):
	health = clamp(health - damage, 0, base_health)
	if health == 0.0:
		var world = get_tree().get_current_scene()
		for drop_item in drop_items:
			var rng = randf()
			#print(rng, ': ', drop_item['chance'], ' - ', drop_item['chance'] <= rng)
			if rng <= drop_item['chance']:
				var drop = drop_item['scene'].instance()
				drop.position = position
				world.add_child(drop)
		queue_free()