class_name Item
extends Node2D

onready var icon = $ItemIcon
onready var lblQtd = $ItemQuantity

var type: String
var quantity: int
var data

func _ready():
	pass # Replace with function body.

func start(data):
	self.data = data
	set_item(data['type'], 'res://art/hud/items/%s_icon.png' % data['icon'], data['quantity'])

func set_item(_type: String, _icon: String, _quantity: int):
	type = _type
	icon.texture = load(_icon)
	if _quantity > 0:
		lblQtd.text = str(_quantity)
	else:
		lblQtd.text = ''

func get_data():
	return data

func get_item_icon():
	return icon.texture

func get_quantity():
	return lblQtd.text
