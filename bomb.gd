extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play()
	connect("finished", self, "do_anim_finished")
	pass # Replace with function body.

func do_anim_finished():
	print('vish')
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
