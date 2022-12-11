extends Node

var resources: Resources
var file_save: String = 'res://saves/save.tres'
var debug_scene: DebugConsole

enum AGE_TYPES {
	YEAR,
	MONTH,
	DAY,
	HOURS
}

func _ready():
	resources = Resources.new()

func start(size: int):
	print('start user data')
	if(resources.get('items_inventory').size() > 0):
		print('load inventory...')
		return #TODO: melhorar load game
	print('init inventory')
	resources.get('items_inventory').clear()
	for _i in range(size):
		resources.get('items_inventory').append(null)

func get_resources():
	return resources	



## ------------------------------------- TIME DATA ------------------------------------ ##
func date_cast(type: int) -> Dictionary:
	if type == AGE_TYPES.YEAR:
		return {
			'year': 1.0,
			'months': 1.0/12.0,
			'days': 1.0/(12*30),
			'hours': 1.0/(12.0*30.0*24.0)
		}
	
	if type == AGE_TYPES.MONTH:
		return {
			'years': 1.0/12.0,
			'months': 1.0,
			'days': 1.0/(12*30),
			'hours': 1.0/(12.0*30.0*24.0)
		}
	
	if type == AGE_TYPES.DAY:
		return {
			'years': 1.0/(12.0*30.0),
			'months': 1.0/(30.0),
			'days': 1.0,
			'hours': 1.0/(24.0)
		}
		
	if type == AGE_TYPES.HOURS:
		return {
			'years': 1.0/(24.0*30.0*12.0),
			'months': 1.0/(24.0*30.0),
			'days': 1.0/24.0,
			'hours': 1.0
		}

	return {'year': 0.0, 'monts': 0.0, 'days': 0.0, 'hours': 0.0}


func tick(_hours: int):
	var to_cast = date_cast(AGE_TYPES.HOURS)
	var p_time	= resources.get('time')
	
	var years	= int(to_cast['years'] * p_time)
	var months	= int(to_cast['months'] * p_time)
	var days	= int(to_cast['days'] * p_time)
	var hours	= int(to_cast['hours'] * p_time)
	
	var n_hours		= hours + _hours
	var n_days		= int(to_cast['days'] * n_hours)
	var n_months	= int(to_cast['months'] * n_hours)
	var n_years		= int(to_cast['years'] * n_hours)
	
	resources.set('time', n_hours)
	
	UserData.log([
		'Year: ', n_years,
		', Months: ', n_months,
		', Days: ', n_days,
		', Hours: ', _hours
	])
	
	#Para futura melhorar de performance não processar items distantes do player...
	get_tree().call_group(
		'time',
		'time_tick',
		n_years - years,
		n_months - months,
		n_days - days,
		n_hours - _hours
	)

func get_date():
	var time	= resources.get('time')
	return time
## ------------------------------------- TIME DATA ------------------------------------ ##

## ------------------------------------- LOG DATA ------------------------------------- ##
func log(args):
	var msg = ''
	if not args is String:
		for arg in args:
			msg += str(arg)
	else:
		msg = args
	if debug_scene != null:
		debug_scene.emit_signal('log_message', msg)
	#emit_signal('log_message', text)
	print(msg)

func set_debug(_debug_scene):
	debug_scene = _debug_scene
## ------------------------------------- LOG DATA ------------------------------------- ##

## ------------------------------------- SAVE DATA ------------------------------------ ##
func load_game() -> bool:
	if ResourceLoader.exists(file_save):
		var res = ResourceLoader.load(file_save)
		if res is Resources:
			resources = res
			
			load_objects(res)
			return true
	return false

func load_objects(res: Resources) -> void:
	#Load map objects and mobs
	var world = get_tree().get_current_scene()
	var line = world.get_node('Line2D')
	for obj in res.get('map_objects'):
		var obj_instance = ItemsData.map_obj_type[obj['type']]['scene'].instance()
		obj_instance.load(obj)
		world.add_child(obj_instance)
		#print(obj['type'], obj_instance, 'position: ', obj['position'])
		#break
	

func save_game() -> bool:
	var d = Directory.new()
	if( !d.dir_exists('res://saves') ):
		var err = d.make_dir_recursive('res://saves')
		if err != OK:
			print('Error to create dir saves: ', err)
			return false
	
	var res = get_resources()
	#print('Inventory to save: ', res.get('items_inventory').size(), ', map_objects: ', res.get('map_objects').size())
	
	res.get('map_objects').clear()
	#print('Inventory to save2: ', res.get('items_inventory').size(), ', map_objects: ', res.get('map_objects').size())
	
	for obj in get_tree().get_nodes_in_group('save_data'):
		if obj is BaseItem:
			res.get('map_objects').append(obj.save_data())
		elif obj is Player:
			res.set('player_data', {
				'position': obj.position
			})
		
	
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
	for idx in range(resources.get('items_inventory').size()):
		var item = resources.get('items_inventory')[idx]
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
	return resources.get('items_inventory')[idx] == null

func set_item_data(idx: int, item):
	return set_item(idx, item['type'], item['quantity'])
	
func set_item(idx: int, _type: String, _quantity: int):
	if idx < 0 || idx >= resources.get('items_inventory').size():
		print('Invalid index: ', idx)
		return
	var config = ItemsData.items[_type]
	var previous_item = resources.get('items_inventory')[idx]
	
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
	
	resources.get('items_inventory')[idx] = item
	return previous_item

func release_item(idx: int):
	var tmp = resources.get('items_inventory')[idx]
	if not is_empty(idx):
		resources.get('items_inventory')[idx] = null
	return tmp

func remove_qty(qtd: int, idx: int = -1, _type: String = ''):
	if idx < 0 and _type == '': return null
	if idx >= 0:
		if resources.get('items_inventory')[idx]['quantity'] > qtd:
			var removed = resources.get('items_inventory')[idx].duplicate()
			resources.get('items_inventory')[idx]['quantity'] -= qtd
			removed['quantity'] = qtd
			return removed
		else:
			return release_item(idx)
	
	var removed = null
	for idx in range(resources.get('items_inventory').size()):
		if qtd == 0:
			return removed
		if resources.get('items_inventory')[idx] == null: continue
		if resources.get('items_inventory')[idx]['type'] == _type:
			if removed == null:
				removed = resources.get('items_inventory')[idx].duplicate()
				removed['quantity'] = 0
			
			if resources.get('items_inventory')[idx]['quantity'] > qtd:
				resources.get('items_inventory')[idx]['quantity'] -= qtd
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
	#print(resources.get('items_inventory'))
	return resources.get('items_inventory')[idx]
## ------------------------------------- INVENTORY ------------------------------------ ##
