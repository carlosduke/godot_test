extends Node

var items = []

func start(size: int):
	items.clear()
	for i in range(size):
		items.append(null)

func add_item(type: String, quantity: int):
	var config = ItemsData.items[type]
	var f_empty = -1
	for idx in range(items.size()):
		var item = items[idx]
		if item == null and not config.stackable:
			set_item_data(idx, {
				'type': type,
				'quantity': quantity
			})
			return
		elif item == null and f_empty < 0:
			f_empty = idx
			continue
		elif item == null: continue
		
		if item['type'] == type and item['quantity'] == config['max_size']: continue
		item['quantity'] += quantity
		if item['quantity'] > config['max_size']:
			quantity = item['quantity'] - config['max_size']
			item['quantity'] = config['max_size']
			continue
		else:
			quantity = 0
		break
	if quantity > 0 and f_empty >= 0:
		set_item(f_empty, type, quantity)
	print('Remain: ', quantity, ', f: ', f_empty)
	return quantity

func is_empty(idx: int):
	return items[idx] == null

func set_item_data(idx: int, item):
	return set_item(idx, item['type'], item['quantity'])
	
func set_item(idx: int, _type: String, _quantity: int):
	if idx < 0 || idx >= items.size():
		print('Invalid index: ', idx)
		return
	var config = ItemsData.items[_type]
	var previous_item = items[idx]
	
	var item = {
		'type': _type,
		'icon': config['icon'],
		'quantity': _quantity,
	}
	
	if previous_item != null and previous_item['type'] == _type and config.stackable:
		item.quantity += previous_item.quantity
		if item.quantity > config.max_size:
			previous_item['quantity'] = item['quantity'] - config.max_size
			item.quantity = config.max_size
		else:
			previous_item = null
	
	items[idx] = item
	return previous_item

func release_item(idx: int):
	var tmp = items[idx]
	if not is_empty(idx):
		items[idx] = null
	return tmp

func get_item(idx: int):
	return items[idx]
