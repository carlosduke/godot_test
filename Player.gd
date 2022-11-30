extends Area2D

signal hit

export(PackedScene) var bullet_scene
#export(PackedScene) var bomb_scene
var bomb_scene = preload("res://bomb.tscn")
export(int) var default_lifes
export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var mouse_pos
var started = false
var lifes
var size_lifes

var startMap
var endMap


func _ready():
	screen_size = get_viewport_rect().size
	size_lifes = $LifeHud.points[0].distance_to($LifeHud.points[1]) / default_lifes
	
	# Static types are necessary here to avoid warnings.
	var camera: Camera2D = $Camera
	
	camera.custom_viewport = $"../.."
	yield(get_tree(), "idle_frame")
	camera.make_current()
	
	hide()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.global_position
	if event is InputEventMouseButton and event.is_pressed():
		var direction = (mouse_pos - position).normalized()
		###shoot(direction)
	#pass


func shoot(tmp):
	if not started: return
	if not $shoot_time.is_stopped():
		return
	
	#print("player: ", $shoot_start.get_global_transform_with_canvas().get_origin())
	#print("mouse: ", mouse_pos)
	$shoot_time.start()
	var bullet = bullet_scene.instance()
	#bullet.start(get_position())
	#bullet.position = Vector2(0, 0)
	
	bullet.global_position = $shoot_start.global_position
	bullet.set_as_toplevel(true)
	var velocity = $shoot_start.get_global_transform_with_canvas().get_origin().direction_to(mouse_pos)
	bullet.start(velocity, startMap, endMap)
	add_child(bullet)
	

func bomb():
	print('inicio')
	var b = bomb_scene.instance()
	
	b.set_as_toplevel(true)
	b.bomb(10, 20)
	add_child(b)

func _process(delta):
	if not started: return
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if Input.is_action_pressed("ui_accept"):
		#shoot(1)
		pass
	
	if Input.is_mouse_button_pressed(1):
		shoot(1)
	if Input.is_mouse_button_pressed(2):
		bomb()	
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	#print(position)
	position += velocity * delta
	position.x = clamp(position.x, startMap.x, endMap.x)
	position.y = clamp(position.y, startMap.y, endMap.y)

	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func start(pos, sm, em):
	position = pos
	lifes = default_lifes
	startMap = sm
	endMap = em
	$Camera.limit_left = sm.x
	$Camera.limit_top = sm.y
	$Camera.limit_right = em.x
	$Camera.limit_bottom = em.y
	
	$LifeHud.points[1][0] = size_lifes * lifes
	
	show()
	$CollisionShape2D.disabled = false
	started = true
	


func _on_Player_body_entered(_body):
	#_body.rola()
	if lifes > 0: lifes -= 1
	else: return
	
	#print("cur size: ", size_lifes * lifes)
	$LifeHud.points[1][0] = size_lifes * lifes
	_body.kill()
	
	emit_signal("hit")
	
func destroy():
	hide()
	started = false	

func get_lifes():
	return lifes
