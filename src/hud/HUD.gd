extends CanvasLayer

signal start_game (newgame)
signal handle_inventory

onready var inventory = $Inventory

func show_message(text):
	$MessageLabel.text = text
	$MessageLabel.show()
	$MessageTimer.start()


func show_game_over():
	show_message("Game Over")
	yield($MessageTimer, "timeout")
	$MessageLabel.text = "Dodge the\nCreeps"
	$MessageLabel.show()
	yield(get_tree().create_timer(1), "timeout")
	$StartButton.show()


func update_score(score):
	$ScoreLabel.text = str(score)
	
func update_lifes(life):
	$ScoreLifes.text = str(life)
	
func handle_inventory():
	inventory.visible = !inventory.visible



func _on_StartButton_pressed():
	$Buttons.hide()
	emit_signal("start_game", true)


func _on_MessageTimer_timeout():
	$MessageLabel.hide()


func _on_ContinueGame_pressed():
	$Buttons.hide()
	emit_signal("start_game", false)

func _on_HUD_handle_inventory():
	handle_inventory()
