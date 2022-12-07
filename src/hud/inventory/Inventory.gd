extends Control

export(int) var cols = 6
export(int) var lines = 4

var item_scn = preload("res://scenes/hud/inventory/Item.tscn")
var holding_item: Item

var stock_size

func _ready():
	stock_size = cols*lines
	for i in range(stock_size):
		UserData.add_item(null)
		var child = $GridContainer.get_child(i)
		child.connect('gui_input', self, 'slot_gui_input', [child, i])
	
	for i in range(stock_size):
		UserData.set_item(i, 'log', randi()%50)
		var slot = $GridContainer.get_child(i)
		slot.set_item(i)

func is_holding():
	return holding_item != null

func release_holding():
	holding_item.queue_free()
	holding_item = null

func slot_gui_input(event: InputEvent, slot: SlotItem, index: int):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.is_action_pressed('mouse_left'):
				#print('Pressed: ', slot, ', index: ', index)
				if is_holding():
					var item_data = holding_item.get_data()
					var previous_data = UserData.set_item_data(index, item_data)
					
					if previous_data != null:
						holding_item.start(previous_data)
						slot.set_item(index)
						return
					
					slot.set_item(index)
					release_holding()
				elif not UserData.is_empty(index):
					slot.release_item()
					holding_item = item_scn.instance()
					holding_item.global_position = event.global_position
					add_child(holding_item)
					
					var data = UserData.release_item(index)
					holding_item.start(data)

func _input(event):
	if event is InputEventMouseMotion and is_holding():
		holding_item.global_position = event.global_position
