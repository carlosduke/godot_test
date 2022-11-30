class_name Mob
extends RigidBody2D

var player
var speed

func start(p, _speed):
	player = p
	speed = _speed

func _ready():
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

func kill():
	queue_free()
