class_name Item
extends TextureRect

onready var icon = $ItemIcon
onready var label = $ItemQuantity

var type
var quantity

func _ready():
	pass # Replace with function body.

func set_item(_type: String, _icon: String, _quantity: int):
	type = _type
	icon.texture = load(_icon)
	if _quantity > 0:
		label.text = str(_quantity)
	else:
		label.text = ''
