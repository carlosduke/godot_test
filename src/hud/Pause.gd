extends CanvasLayer

signal resume_game

func _ready():
	pass # Replace with function body.

func _on_Resume_pressed():
	emit_signal('resume_game')


func _on_Pause_visibility_changed():
	if visible:
		$Inventory.refresh()
