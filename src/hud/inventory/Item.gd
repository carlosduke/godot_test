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
	set_item()

func set_item():
	icon.texture = data['icon']
	if data['quantity'] > 0:
		lblQtd.text = str(data['quantity'])
	else:
		lblQtd.text = ''

func get_data():
	return data

