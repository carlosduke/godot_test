extends CanvasLayer

signal resume_game

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Resume_pressed():
	emit_signal('resume_game')


func _on_Pause_visibility_changed():
	if visible:
		$Inventory.refresh()
