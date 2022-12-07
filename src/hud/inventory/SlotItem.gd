class_name SlotItem
extends TextureRect

onready var icon = $ItemIcon
onready var lblQtd = $ItemQuantity

func set_item(idx: int):
	if UserData.is_empty(idx):
		release_item()
	else:
		var data = UserData.get_item(idx)
		icon.texture = data['icon']
		lblQtd.text = str(data['quantity'])

func release_item():
	icon.texture = null
	lblQtd.text = ''
	
