extends Control

export(int) var cols = 6
export(int) var lines = 4

var stock_size
var items = []
signal item_change()

func _ready():
	stock_size = cols*lines
	for i in range(stock_size):
		items.append(null)
		var child = $GridContainer.get_child(i)
		child.connect('gui_input', self, 'slot_gui_input', [child, i])
	
	print(add_item(0, 'log', "res://art/hud/items/log_icon.png", 10))
	#print(items)

func slot_gui_input(event: InputEvent, item: Item, index: int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_action_pressed('mouse_left'):
				print('Pressed: ', item, ', index: ', index)
			elif event.is_action_released("mouse_left"):
				print('Released: ', item, ', index: ', index)

func add_item(idx: int, _type: String, _icon: String, _quantity: int):
	if idx < 0 || idx >= stock_size:
		print('Invalid index: ', idx)
		return
	var previous_item = items[idx]
	items[idx] = {
		'type': _type,
		'icon': _icon,
		'quantity': _quantity,
	}
	var item = $GridContainer.get_child(0)
	item.set_item(_type, _icon, _quantity)
	return previous_item

