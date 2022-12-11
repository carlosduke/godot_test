class_name HealthBar
extends TextureProgress

var bar_green = preload("res://art/health_green.png")
var bar_yellow = preload("res://art/health_yellow.png")
var bar_red = preload("res://art/health_red.png")

onready var display = $HealthText
var _base_health

func _ready():
	pass # Replace with function body.

func start(base_health):
	_base_health = base_health
	set_health(base_health)
	display.text = '%d/%d' % [value, max_value]

func set_health(health):
	var _value = health/_base_health
	
	if _value >= 0.7:
		texture_progress = bar_green
	elif _value >= 0.3:
		texture_progress = bar_yellow
	else:
		texture_progress = bar_red
	value = _value * max_value
	display.text = '%d/%d' % [value, max_value]
	#print('Size: ', rect_size, ', Max: ', max_value, ', Value: ', value, ' - ', _value)
