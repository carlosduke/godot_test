extends Area2D


var velocity
var screen_size # Size of the game window.
export(int) var bullet_speed
var startMap
var endMap

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

func start(v, sm, em):
	velocity = v * bullet_speed
	startMap = sm
	endMap = em
	
func _process(delta):
	position += velocity * delta
	#position.x = clamp(position.x, -10, screen_size.x+10)
	#position.y = clamp(position.y, -10, screen_size.y+10)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Bullet_body_entered(body):
	if body is Mob:
		body.kill()
		queue_free()
	
