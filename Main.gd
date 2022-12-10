extends Node

onready var tilemap = $Navigation2D/TileMap
onready var debug = $Debug
onready var hud = $HUD

var base_path = preload("res://scenes/hud/Path.tscn")

export(PackedScene) var mob_scene 
export(int) var height = 600
export(int) var width = 600

var started = false

var score
var target = load("res://art/target.png")
var paused = false

func _ready():
	randomize()
	

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and not paused:
		handle_pause_resume()
	
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_MIDDLE and event.is_pressed():
		#print('Add Mob, ', event.global_position)
#		if not $MobTimer.is_stopped(): return
#		$MobTimer.start()
		
		add_child(create_mob($Player.get_global_mouse_position()))
	if event.is_action_pressed("ui_debug"):
		debug.emit_signal('handle_display')
		
	if event.is_action_pressed("ui_inventory"):
		hud.emit_signal('handle_inventory')

func handle_pause_resume():
	paused = not paused
	get_tree().paused = paused
	$Pause.visible = paused

func handle_hit():
	$HUD.update_lifes($Player.get_lifes())
	if $Player.get_lifes() == 0:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		Input.set_custom_mouse_cursor(null)
		$ScoreTimer.stop()
		$MobTimer.stop()
		$HUD.show_game_over()
		$Music.stop()
		$DeathSound.play()
		$Player.destroy()

func generate_map(_seed):
#	seed(_seed)
	
	var noise = OpenSimplexNoise.new()
	noise.seed = _seed
	noise.octaves = 2
	noise.period = 30.0
	noise.persistence = 0.8
	
	var map = []
	for c in range(0,height):
		map.append([])
		for l in range(0,width):
			#var n = rng.randi()
			#var alt = rng.randf_range(0,1)
			var noise_v = noise.get_noise_2d(c,l)
			map[c].append(noise_v)
			#print(alt, ', ', tmp)
			
	return map

func between(v, _min, _max):
	return _min <= v && v < _max

func create_map_objects():
	for c in range(0, height):
		for l in range(0,width):
			var pos = Vector2(c,l)
			var alt = UserData.get_resources().get('map_alt')[c][l]
			var temp = UserData.get_resources().get('map_temp')[c][l]
			
			for k in ItemsData.map_terrain:
				var terrain = ItemsData.map_terrain[k]
				if between(alt, terrain.alt.x, terrain.alt.y) and between(temp, terrain.temp.x, terrain.temp.y):
					var tile = terrain.tile
					if k in ItemsData.map_objs:
						var obj = ItemsData.map_objs[k]
						if randf() <= obj['prob']:
							#print(obj['name'], ': ', k)
							var sobj = obj['scene'].instance()
							sobj.position = pos * tilemap.cell_size + tilemap.position
							#print("tile: ", k , " - ", pos, ": ", sobj.position, ", ", $Navigation2D/TileMap.cell_size)
							#print(sobj.position, ', C: ', c, ', L: ', l)
							add_child(sobj)
					break

func set_tiles():
	for c in range(0, height):
		for l in range(0,width):
			var pos = Vector2(c,l)
			var alt = UserData.get_resources().get('map_alt')[c][l]
			var temp = UserData.get_resources().get('map_temp')[c][l]
			
			var tile = 0
			for k in ItemsData.map_terrain:
				var terrain = ItemsData.map_terrain[k]
				if between(alt, terrain.alt.x, terrain.alt.y) and between(temp, terrain.temp.x, terrain.temp.y):
					tile = terrain.tile
#					if k in ItemsData.map_objs:
#						var obj = ItemsData.map_objs[k]
#						if randf() <= obj['prob']:
#							var sobj = obj['scene'].instance()
#							sobj.position = pos * tilemap.cell_size + tilemap.position
#							add_child(sobj)
					break

			tilemap.set_cellv(pos, tile)

func new_map(_seed):
	seed(_seed)
	var seed_alt = randi()
	var seed_temp = randi()

	UserData.get_resources().set('map_alt', generate_map(seed_alt))
	UserData.get_resources().set('map_temp', generate_map(seed_temp))
	
	set_tiles()
	create_map_objects()
	
# Called when the node enters the scene tree for the first time.

func start_map(_seed, newgame: bool):
	if newgame or not UserData.load_game():
		new_map(_seed.hash())
	else:
		set_tiles()
		for obj in UserData.get_resources().get('map_objects'):
			if obj['type'] == 'mob': #TODO: melhorar, ta uma merda
				add_child(create_mob(obj['position']))
				continue
			var obj_data = ItemsData.map_obj_type[obj['type']]
			var sobj = obj_data['scene'].instance()
			sobj.position = obj['position']
			sobj.set_health(obj['health'])
			sobj.set_damage(obj['damage'])
			add_child(sobj)
	
	var size = Vector2(height, width) * tilemap.cell_size
	var min_pos = tilemap.position
	var max_pos = size + tilemap.position #* $TileMap.cell_size
	print(max_pos, "-", size, "-", tilemap.position* tilemap.cell_size)
	
	var load_player_data = UserData.get_resources().get('player_data')
	if not load_player_data.empty():
		$Player.start(load_player_data['position'], min_pos, max_pos)
	else:
		$Player.start($StartPosition.position, min_pos, max_pos)	
	started = true
	#print(map_alt)
	#$Player.show()
	
func start_game(newgame: bool):
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().call_group("mobs", "queue_free")
	get_tree().call_group("map_element", "queue_free")
	
	score = 0
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_lifes($Player.get_lifes())
	$HUD.show_message("Get Ready")
	#Input.set_custom_mouse_cursor(target)

	start_map(str(randi()), newgame)

func create_mob(pos:Vector2):
	var mob = mob_scene.instance()
	mob.global_position = pos
	var path_mob = base_path.instance()
	path_mob.global_position = Vector2(0.0,0.0)
	add_child(path_mob)
	
	mob.start($Navigation2D, path_mob)
	mob.connect('tree_exiting', path_mob, 'queue_free')
	mob.scale = Vector2(0.125, 0.125)
	return mob

func _on_MobTimer_timeout():
	var prob_mob = 0.1
	if randf() < prob_mob:
		var size = Vector2(height, width) * tilemap.cell_size
		var min_pos = tilemap.position
		var max_pos = size + tilemap.position #* $TileMap.cell_size
		var pos = Vector2(
			rand_range(min_pos.x, max_pos.x),
			rand_range(min_pos.y, max_pos.y)
		)
		add_child(create_mob(pos))
		print('New Mob Created: ', pos)
	pass

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
#	$ScoreTimer.start()
	pass

func _on_Pause_resume_game():
	handle_pause_resume()

var last_tile_id
func _process(delta):
	if not started: return
	
	var local_position = tilemap.to_local($Player.global_position)
	var cell = tilemap.world_to_map(local_position)
	var tile_id = tilemap.get_cellv(cell)
	if tile_id < 0: return
	
	if last_tile_id != tile_id:
		#print('Player: ', $Player.global_position, ', Cell: ', cell, ', ID: ', tile_id)
		last_tile_id = tile_id
		$Player.change_terrain({
			'id': tile_id,
			'name': ItemsData.tile_id_name[tile_id]
		})
	#print('TileID: ', tile_id)
