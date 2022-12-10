class_name DebugConsole
extends CanvasLayer

onready var log_data = $Console/Log
onready var console = $Console
onready var game_status = $GameStatus
signal handle_display
signal log_message (message)

func _ready():
	UserData.set_debug(self)

func _on_LineEdit_text_entered(new_text):
	handle_command(new_text)

func _on_Debug_handle_display():
	handle_display()

func _process(delta):
	display_status()

func display_status():
	var status = ''
	status += 'FPS: %d\n' % Performance.get_monitor(Performance.TIME_FPS)
	status += 'Objects: %d\n' % Performance.get_monitor(Performance.OBJECT_COUNT)
	
	game_status.text = status

func handle_display():
	console.visible = !console.visible

func _log(cmd: String):
	log_data.text += cmd + '\n'
	log_data.scroll_vertical = 9999999

func handle_command(cmd: String):
	if cmd.begins_with(':'):
		var parts = cmd.split(' ', false)
		if parts.size() >= 1:
			if parts[0] == ':add_inventory':
				UserData.add_item(parts[1], int(parts[2]))
	_log(cmd)

func _on_Debug_log_message(message):
	_log(message)
