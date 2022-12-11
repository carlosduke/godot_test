class_name BaseItem
extends RigidBody2D

export(float) var base_health = 10.0
export(float) var base_damage = 0.0
signal killed

var health_bar: HealthBar

var lifeStatusBase = preload("res://src/life/LifeStatus.gd")
var status: LifeStatus
var damage: float

var drop_items = []
export var type: String

func _ready():
	damage = base_damage
	if status == null:
		status = lifeStatusBase.new()
		set_health(base_health)
		return
	set_health(get_health())

func save_data():
	return {
		'type': type,
		'position': position,
		'damage': damage,
		'status': status
	}

func load(data):
	position = data['position']
	self.status = data['status']
	UserData.log([status.health])

func get_status():
	return status

func set_type(type):
	self.type =  type

func get_type():
	return type

func get_health():
	return status.health

func get_base_health():
	return base_health

func set_health(_health):
	status.health = _health

func set_health_bar(bar: HealthBar):
	health_bar = bar
	bar.start(base_health)
	bar.set_health(status.health)

func add_drop(chance: float, scene: PackedScene, type: String, _min: int, _max: int):
	drop_items.append({
		'chance': chance,
		'scene': scene,
		'type': type,
		'min': _min,
		'max': _max
	})

func apply_damage(damage: float):
	var health = clamp(status.health - damage, 0, base_health)
	status.health = health
	UserData.log(['damage: ', damage, ', Health: ', health, ', Base: ', base_health])
	if health_bar:
		health_bar.set_health(health)

	if health == 0.0:
		var world = get_tree().get_current_scene()
		for drop_item in drop_items:
			var rng = randf()
			#print(rng, ': ', drop_item['chance'], ' - ', drop_item['chance'] <= rng)
			if rng <= drop_item['chance']:
				var drop = drop_item['scene'].instance()
				if drop is DropItem:
					var qtd_drop = (randi()%drop_item['max'] - drop_item['min']) + drop_item['min']
					drop.start(qtd_drop)
					drop.position = position
					world.add_child(drop)
				else:
					drop.queue_free()
		emit_signal('killed')
		queue_free()

func apply_health(_health: float):
	var health = clamp(status.health + _health, status.health, base_health)
	status.health = health
	#UserData.log(['Health: ', _health, ', status: ', status.health, ', base: ', base_health])
	if health_bar:
		health_bar.set_health(health)

func add_age(hours: int):
	status.add_age(hours)

func get_age(type: int) -> float:
	return float(UserData.cast_date(type, status.age_hours))

func get_damage():
	return damage

func set_damage(damage):
	self.damage = damage
