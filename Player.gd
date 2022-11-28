extends Area2D

signal hit

export(PackedScene) var bullet_scene
export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.
var mouse_pos
var started = false

func _ready():
	screen_size = get_viewport_rect().size
	print('started')
	hide()

func _input(event):
	if event is InputEventMouseMotion:
		mouse_pos = event.position
	if event is InputEventMouseButton and event.is_pressed():
		var direction = (mouse_pos - position).normalized()
		shoot(direction)
	#pass


func shoot(tmp):
	if not started: return
	if not $shoot_time.is_stopped():
		return
	
	$shoot_time.start()
	var bullet = bullet_scene.instance()
	#bullet.start(get_position())
	#bullet.position = Vector2(0, 0)
	bullet.global_position = $shoot_start.global_position
	bullet.set_as_toplevel(true)
	var velocity = global_position.direction_to(mouse_pos)
	bullet.start(velocity)
	add_child(bullet)
	
#	print('rola')

func _process(delta):
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
	
	if Input.is_action_pressed("mouse_left"):
		shoot(1)

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()

	#print(position)
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	started = true
	


func _on_Player_body_entered(_body):
	#_body.rola()
	emit_signal("hit")
	$LifeHud.points[1][0] = $LifeHud.points[1][0] - 10
	_body.kill()
	
func destroy():
	hide()
	started = false
	
