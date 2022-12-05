extends Weapon

var started = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.stop()
	
func bomb(x, y):
	$AnimatedSprite.play("default")

func _process(delta):
	if $AnimatedSprite.frame >= 24:
		destroy()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func destroy():
	queue_free()


func _on_Timer_timeout():
	destroy()


func _on_bomb_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body is Mob:
		body.kill(get_damage())
	
	if body is BaseItem:
		body.apply_damage(get_damage())
