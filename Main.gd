extends Node

export(PackedScene) var mob_scene 
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
	#$Music.play()
	

func create_mob():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()
	var speed = rand_range(150.0, 250.0)
	
	mob.start($Player, speed)
	
	
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
	mob.rotation = direction

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
	$MobTimer.start()
	$ScoreTimer.start()
	pass


func _on_Pause_resume_game():
	handle_pause_resume()
