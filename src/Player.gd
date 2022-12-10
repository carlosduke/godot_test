class_name Player
extends KinematicBody2D

signal hit

export(PackedScene) var bullet_scene
#export(PackedScene) var bomb_scene
var bomb_scene = preload("res://scenes/items/bomb.tscn")
export(int) var default_lifes = 10
export var base_speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

export(float) var base_health = 10.0
var health: float

var mouse_pos
var started = false
var lifes
var size_lifes

var startMap
var endMap
var current_terrain

var zoom_size = Vector2(.1, .1)

var terrain_stats = {
	'water': {
		'speed': -20
	},
	'ice': {
		'speed': -50
	},
	'grass': {
		'speed': 30
	}
}

func _ready():
	screen_size = get_viewport_rect().size
	
	# Static types are necessary here to avoid warnings.
	var camera: Camera2D = $Camera
	
	camera.custom_viewport = $"../.."
	yield(get_tree(), "idle_frame")
	camera.make_current()
	
	hide()

func _unhandled_input(event):
	if not started: return
	if event is InputEventMouseMotion:
		mouse_pos = event.global_position
	if event is InputEventMouseButton and event.is_pressed():
		var direction = (mouse_pos - position).normalized()
		###shoot(direction)
	
	# Zoom control...
	if event.is_action("zoom_in"):
		zoom(-zoom_size)
	if event.is_action("zoom_out"):
		zoom(zoom_size)

func control_movement(delta: float):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		shoot()
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		bomb(get_global_mouse_position())	
	
	var speed = base_speed
	if current_terrain['name'] in terrain_stats:
		var cur_stats = terrain_stats[current_terrain['name']]
		if 'speed' in cur_stats:
			var speed_change = terrain_stats[current_terrain['name']]['speed']
			speed += speed_change
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

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


func shoot():
	if not started: return
	if not $shoot_time.is_stopped():
		return
	
	$shoot_time.start()
	var bullet = bullet_scene.instance()
	
	bullet.global_position = $shoot_start.global_position
	bullet.set_as_toplevel(true)
	var velocity = $shoot_start.get_global_transform_with_canvas().get_origin().direction_to(mouse_pos)
	bullet.start(velocity, startMap, endMap)
	add_child(bullet)
	
func bomb(position):
	if not $bomb_time.is_stopped():
		return
	$bomb_time.start()
	if UserData.remove_qty(1, -1,'bomb') == null: return
	
	var b = bomb_scene.instance()
	
	b.set_as_toplevel(true)
	b.position.x = position[0]
	b.position.y= position[1]
	b.bomb(1,1)
	add_child(b)

func _process(delta):
	if not started: return
	
	control_movement(delta)
	

func change_terrain(terrain):
	current_terrain = terrain


func start(pos, sm, em):
	position = pos
	lifes = default_lifes
	startMap = sm
	endMap = em
	$Camera.limit_left = sm.x
	$Camera.limit_top = sm.y
	$Camera.limit_right = em.x
	$Camera.limit_bottom = em.y
	
	show()
	$CollisionShape2D.disabled = false
	
	health = base_health
	$HealthBar.start(base_health)
	started = true
	
func zoom(zoom_size):
	$Camera.zoom += zoom_size
	$Camera.zoom.x = clamp($Camera.zoom.x, 0.4, 2)
	$Camera.zoom.y = clamp($Camera.zoom.y, 0.4, 2)


func _on_Player_body_entered(_body):
#	if _body is BaseItem:
#		health = clamp(health - _body.get_damage(), 0, base_health)
#		$HealthBar.set_health(health)
	if _body is DropItem:
		var remain = UserData.add_item(_body.get_type(), _body.get_quantity())
		_body.set_quantity(remain)

func destroy():
	hide()
	started = false	

func get_lifes():
	return lifes
