class_name Mob
extends BaseItem

var player
var speed
var navigation
onready var path = $Line2D
export(PackedScene) var bomb_scene

func _ready():
	path.position = Vector2(0,0) - position #TODO: melhorar a implementação do path
	set_health_bar($HealthBar)
	speed = rand_range(200.0, 400.0)
	
	add_drop(0.7, bomb_scene, 'bomb', 1, 7)
	
	$AnimatedSprite.playing = true
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	#print('mob started: ', position)
	$PathTimer.start()
	find_path()

func find_path():
	var path = navigation.get_simple_path(position, player.global_position, true)
	self.path.points = path

func start(player, nav):
	navigation = nav
	self.player = player
	#self.path = path

func _process(delta):
#	#if navigation == null: return
#	var dir_player = position.direction_to(player.position)
#	#var cur_velocity = linear_velocity
#	#print("process: ", dir_player)
#	var velocity = position.direction_to(player.position) * speed * delta
#	linear_velocity = velocity
#	if path == null:
#		path = navigation.get_simple_path(position, player.global_position, true)
#		$Line2D.points = path
#	var path = navigation.get_simple_path(position, player.global_position, true)
#	self.path.points = path
	#print('mob: ', position, 'player: ', player.position, 'lines: ', $Line2D.position)
	#$Line2D.points = path
	pass

func _physics_process(delta):
	var points = path.points
	for i in range(points.size()):
		var d = position.distance_to(points[i])
		if d > 2:
			var velocity = position.direction_to(points[i]) * speed * delta
			linear_velocity = velocity
			#print(i, ': ', d, ' - ', linear_velocity)
			break
		else:
			path.remove_point(0)
	
	
func _on_VisibilityNotifier2D_screen_exited():
	#queue_free()
	pass

#func kill(damage):
#	if lifes > 0: lifes = lifes - damage
#	$LifeHud.points[1][0] = size_lifes * lifes
#
#	if lifes <= 0:
#		queue_free()


func _on_Mob_killed():
	path.queue_free()


func _on_PathTimer_timeout():
	find_path()
