extends Node

export(PackedScene) var mob_scene 
export(int) var height = 600
export(int) var width = 600

var map_alt = []
var map_temp = []
var started = false

var score
var target = load("res://art/target.png")
var paused = false

func _ready():
	randomize()
	
	
	$MobPath.get_curve().add_point(Vector2(0,0))
	

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		handle_pause_resume()

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

var map_objs = {
	"sand": {
		"name": "cactus",
		"prob": 0.005,
		"scene": preload("res://scenes/map/Cactus.tscn")
	},
	"grass": {
		"name": "tree",
		"prob": 0.01,
		"scene": preload("res://scenes/map/Tree.tscn")
	},
	"ice": {
		"name": "snow_man",
		"prob": 0.005,
		"scene": preload("res://scenes/map/SnowMan.tscn")
	}
}

var tile_id_name = {
	0: 'grass',
	1: 'water',
	2: 'ice',
	3: 'earth',
	4: 'sand'
}

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

func set_tiles():
	for c in range(0, height):
		for l in range(0,width):
			var pos = Vector2(c,l)
			var alt = map_alt[c][l]
			var temp = map_temp[c][l]
			
			var tile = 0
			for k in map_terrain:
				var terrain = map_terrain[k]
				if between(alt, terrain.alt.x, terrain.alt.y) and between(temp, terrain.temp.x, terrain.temp.y):
					tile = terrain.tile
					if k in map_objs:
						var obj = map_objs[k]
						if randf() <= obj['prob']:
							#print(obj['name'], ': ', k)
							var sobj = obj['scene'].instance()
							sobj.position = pos * $TileMap.cell_size + $TileMap.position
							#print("tile: ", k , " - ", pos, ": ", sobj.position, ", ", $TileMap.cell_size)
							#print(sobj.position)
							add_child(sobj)
					break

			$TileMap.set_cellv(pos, tile)

func new_map(_seed):
	seed(_seed)
	var seed_alt = randi()
	var seed_temp = randi()
	
	var map_elements = get_tree().get_nodes_in_group('map_element')
	for element in map_elements:
		element.queue_free()

	map_alt = generate_map(seed_alt)
	map_temp = generate_map(seed_temp)
	set_tiles()
# Called when the node enters the scene tree for the first time.

func start_map(_seed):
	new_map(_seed.hash())
	
	var size = Vector2(height, width) * $TileMap.cell_size
	var min_pos = $TileMap.position
	var max_pos = size + $TileMap.position #* $TileMap.cell_size
	print(max_pos, "-", size, "-", $TileMap.position* $TileMap.cell_size)
	$Player.start($StartPosition.position, min_pos, max_pos)
	started = true
	#print(map_alt)
	#$Player.show()
	

func new_game():
	#Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	get_tree().call_group("mobs", "queue_free")
	score = 0
	
	$Player.start($StartPosition.position, $StartMap.position, $EndMap.position)
	
	$StartTimer.start()
	$HUD.update_score(score)
	$HUD.update_lifes($Player.get_lifes())
	$HUD.show_message("Get Ready")
	Input.set_custom_mouse_cursor(target)
	
	start_map('3')
	#$Music.play()
	

func create_mob():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()
	var speed = rand_range(75.0, 150.0)
	
	var mob_lifes = int(score/10)
	if mob_lifes < 2: mob_lifes = 2
	mob.start($Player, speed, mob_lifes)
	
	
	# Choose a random location on Path2D.
	var mob_spawn_location = get_node("MobPath/MobSpawnLocation")
	mob_spawn_location.offset = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	
	var angle = rand_range(0, 360)
	mob.position = $Player.position + Vector2(
		cos(angle),
		sin(angle)
	) * 600
	
	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	#mob.rotation = direction

	# Choose the velocity for the mob.
	#var velocity = Vector2(rand_range(150.0, 250.0), 0.0)
	
	#mob.linear_velocity = velocity.(direction)

	# Spawn the mob by adding it to the Main scene.
	return mob
	#add_child(mob)

func _on_MobTimer_timeout():
	add_child(create_mob())

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_StartTimer_timeout():
#	$MobTimer.start()
#	$ScoreTimer.start()
	pass

func _on_Pause_resume_game():
	handle_pause_resume()

var last_tile_id
func _process(delta):
	if not started: return
	
	var local_position = $TileMap.to_local($Player.global_position)
	var cell = $TileMap.world_to_map(local_position)
	var tile_id = $TileMap.get_cellv(cell)
	if tile_id < 0: return
	
	if last_tile_id != tile_id:
		#print('Player: ', $Player.global_position, ', Cell: ', cell, ', ID: ', tile_id)
		last_tile_id = tile_id
		$Player.change_terrain({
			'id': tile_id,
			'name': tile_id_name[tile_id]
		})
	#print('TileID: ', tile_id)
