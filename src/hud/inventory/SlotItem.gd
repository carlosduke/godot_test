class_name SlotItem
extends TextureRect

onready var icon = $ItemIcon
onready var lblQtd = $ItemQuantity

func set_item(idx: int):
	if UserData.is_empty(idx):
		release_item()
	else:
		var data = UserData.get_item(idx)
		var icon_img = load('res://art/hud/items/%s_icon.png' % data['icon'])
		if icon_img:
			icon.texture = icon_img
			lblQtd.text = str(data['quantity'])

func release_item():
	icon.texture = null
	lblQtd.text = ''
	
