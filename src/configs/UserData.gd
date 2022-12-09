extends Node

var resources: Resources
var items = []
var file_save: String = 'res://saves/save.tres'

func _ready():
	resources = Resources.new()

func start(size: int):
	items.clear()
	for _i in range(size):
		items.append(null)

func get_resources():
	return resources	



## ------------------------------------- SAVE DATA ------------------------------------ ##
func load_game() -> bool:
	if ResourceLoader.exists(file_save):
		var res = ResourceLoader.load(file_save)
		if res is Resources:
			resources = res
			return true
	return false

func save_game() -> bool:
	var res = get_resources()
	res.map_objects.clear()
	for obj in get_tree().get_nodes_in_group('save_data'):
		if obj is BaseItem:
			res.map_objects.append({
				'type': obj.get_type(),
				'position': obj.position,
				'health': obj.get_health(),
				'damage': obj.get_damage(),
			})
		elif obj is Player:
			res.player_data = {
				'position': obj.position
			}
		
	
	var status = ResourceSaver.save(file_save, res)
	print(status)
	return status == OK

## ------------------------------------- SAVE DATA ------------------------------------ ##

## ------------------------------------- INVENTORY ------------------------------------ ##
func add_item(type: String, quantity: int):
	var config = ItemsData.items[type]
	if config == null: return
	var f_empty = -1
	
	#print('Type: ', type, ', Qtd: ', quantity)
	for idx in range(items.size()):
		var item = items[idx]
		if item == null and not config.stackable:
			set_item_data(idx, {
				'type': type,
				'quantity': quantity
			})
			print('Empty Slot not stackable')
			return
		elif item == null and f_empty < 0:
			f_empty = idx
			continue
		elif item == null: continue
		
		if item['type'] != type: continue
		if item['quantity'] == config['max_size']: continue
		item['quantity'] += quantity
		if item['quantity'] > config['max_size']:
			quantity = item['quantity'] - config['max_size']
			item['quantity'] = config['max_size']
			continue
		else:
			quantity = 0
		break
	if quantity > 0 and f_empty >= 0:
		if quantity > config['max_size']:
			set_item(f_empty, type, config['max_size'])
			return add_item(type, quantity - config['max_size'])
		set_item(f_empty, type, quantity)
		quantity = 0
	#print('Remain: ', quantity, ', f: ', f_empty)
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

func remove_qty(qtd: int, idx: int = -1, _type: String = ''):
	if idx < 0 and _type == '': return null
	if idx >= 0:
		if items[idx]['quantity'] > qtd:
			var removed = items[idx].duplicate()
			items[idx]['quantity'] -= qtd
			removed['quantity'] = qtd
			return removed
		else:
			return release_item(idx)
	
	var removed = null
	for idx in range(items.size()):
		if qtd == 0:
			return removed
		if items[idx] == null: continue
		if items[idx]['type'] == _type:
			if removed == null:
				removed = items[idx].duplicate()
				removed['quantity'] = 0
			
			if items[idx]['quantity'] > qtd:
				items[idx]['quantity'] -= qtd
				removed['quantity'] = qtd
				#print('Removed...', removed)
				return removed
			else:
				var released = release_item(idx)
				removed['quantity'] += released['quantity']
				qtd -= released['quantity']
				#print('Released..', released, ', Remain: ', qtd)
	return null
	
func get_item(idx: int):
	return items[idx]
## ------------------------------------- INVENTORY ------------------------------------ ##
