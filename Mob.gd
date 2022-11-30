class_name Mob
extends RigidBody2D

var player
var speed

var default_lifes
var lifes
var size_lifes

func start(p, _speed, _default_lifes = 2):
	player = p
	speed = _speed
	default_lifes = _default_lifes


func _ready():
	lifes = default_lifes
	size_lifes = $LifeHud.points[0].distance_to($LifeHud.points[1]) / default_lifes
	$LifeHud.points[1][0] = size_lifes * lifes
	$LifeHud.rotation_degrees = 0
	$Level.text = "Level: " + str(default_lifes)
	
	$AnimatedSprite.playing = true
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	
func _process(delta):
	var dir_player = position.direction_to(player.position)
	#var cur_velocity = linear_velocity
	#print("process: ", dir_player)
	var velocity = position.direction_to(player.position) * speed
	linear_velocity = velocity
	
	
	


func _on_VisibilityNotifier2D_screen_exited():
	#queue_free()
	pass

func kill(who):
	if lifes > 0: lifes = lifes - who.get_dano()
	$LifeHud.points[1][0] = size_lifes * lifes
	
	if lifes <= 0:
		queue_free()
