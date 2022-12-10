class_name Resources
extends Resource

export var save_data = {
	'map_alt': [],
	'map_temp': [],
	'map_objects': [],
	'player_data': {},
	'items_inventory': []
}

func get(key: String):
	return save_data[key]

func set(key: String, data):
	save_data[key] =  data
