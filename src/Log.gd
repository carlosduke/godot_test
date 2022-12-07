class_name DropItem
extends StaticBody2D

#TODO: criar generico
export(String) var type = 'log'

onready var lblQtd = $lblQtd
var quantity

func start(quantity):
	self.quantity = quantity

func _ready():
	set_quantity(quantity)

func get_quantity():
	return quantity

func get_type():
	return type

func set_quantity(qtd: int):
	if qtd <= 0:
		queue_free()
		return
	quantity = qtd
	lblQtd.text = str(qtd)
