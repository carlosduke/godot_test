extends Node


#TODO: passar para arquivo de config
var items = {
	'log': {
		'icon': preload("res://art/hud/items/log_icon.png"),
		'stackable': true,
		'max_size': 99
	},
	'bomb': {
		'icon': preload("res://art/hud/items/bomb_icon.png"),
		'stackable': true,
		'max_size': 10
	}
}

var map_terrain = {
	"water": {
		"alt": Vector2(-1, -0.2),
		"temp": Vector2(-1, 1),
		"tile": 1
	},
	"grass": {
		"alt": Vector2(-0.2, 0.5),
		"temp": Vector2(-0.5, 0.4),
		"tile": 0
	},
	"sand": {
		"alt": Vector2(-0.2, 1),
		"temp": Vector2(0.4, 1),
		"tile": 4
	},
	"earth": {
		"alt": Vector2(0.5, 1),
		"temp": Vector2(-0.5,0.4),
		"tile": 3
	},
	"ice": {
		"alt": Vector2(-0.2, 1),
		"temp": Vector2(-1,-0.5),
		"tile": 2
	}
}


var map_obj_type = {
	'tree': {
		"scene": preload("res://scenes/map/Tree.tscn")
	},
	'cactus': {
		"scene": preload("res://scenes/map/Cactus.tscn")
	},
	'snow_man': {
		"scene": preload("res://scenes/map/SnowMan.tscn")
	}
}


var map_objs = {
	"sand": {
		"name": "cactus",
		"prob": 0.005,
		'scene': map_obj_type['cactus']['scene']
	},
	"grass": {
		"name": "tree",
		"prob": 0.01,
		'scene': map_obj_type['tree']['scene']
	},
	"ice": {
		"name": "snow_man",
		"prob": 0.005,
		'scene': map_obj_type['snow_man']['scene']
	}
}

var tile_id_name = {
	0: 'grass',
	1: 'water',
	2: 'ice',
	3: 'earth',
	4: 'sand'
}
