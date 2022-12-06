extends Node

var items = []

func add_item(item):
	items.append(item)

func is_empty(idx: int):
	return items[idx] == null

func set_item_data(idx: int, item):
	return set_item(idx, item['type'], item['icon'], item['quantity'])
	
func set_item(idx: int, _type: String, _icon: String, _quantity: int):
	if idx < 0 || idx >= items.size():
		print('Invalid index: ', idx)
		return
	var previous_item = items[idx]
	var item = {
		'type': _type,
		'icon': _icon,
		'quantity': _quantity,
	}
	items[idx] = item
	return previous_item

func release_item(idx: int):
	var tmp = items[idx]
	if not is_empty(idx):
		items[idx] = null
	return tmp

func get_item(idx: int):
	return items[idx]
