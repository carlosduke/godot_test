class_name Mob
extends BaseItem

var target
var speed
var navigation
var path
export(PackedScene) var bomb_scene
export(float) var max_dist

func _ready():
	set_health_bar($HealthBar)
	speed = rand_range(400.0, 800.0)
	
	add_drop(0.7, bomb_scene, 'bomb', 1, 7)
	
	$AnimatedSprite.playing = true
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	#print('mob started: ', position)
	$PathTimer.start()
	find_path()

func find_path():
	if target != null:
		var dist = global_position.distance_to(target.global_position)
		if dist > max_dist:
			target = null
			self.path.clear_points()
			linear_velocity = Vector2(0.0, 0.0)
			return
		var path = navigation.get_simple_path(position, target.global_position, true)
		self.path.points = path

func start(nav, path):
	navigation = nav
	self.path = path

func _process(delta):
	pass

func _physics_process(delta):
	var points = path.points
	for i in range(points.size()):
		var d = position.distance_to(points[i])
		if d > 2:
			var velocity = position.direction_to(points[i]) * speed * delta
			linear_velocity = velocity
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


func _on_ViewArea_body_entered(body):
	if body is Player:
		target = body
		UserData.log(['New Target: ', body])
	
