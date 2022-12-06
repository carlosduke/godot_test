extends BaseItem

func _ready():
	set_health_bar($HealthBar)


func _on_Cactus_body_entered(body):
	print(body)
	if body is Player:
		print(body)


func _on_Cactus_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print(body)
	pass # Replace with function body.
