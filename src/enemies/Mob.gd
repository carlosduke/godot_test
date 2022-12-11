class_name Mob
extends BaseItem

const tree_scene = preload("res://scenes/map/Tree.tscn")

var target
var foods = {}
var player: Player

var damage_targets = []

var speed
var navigation
var path
export(PackedScene) var bomb_scene
export(float) var max_dist

func _ready():
	set_health_bar($HealthBar)
	speed = rand_range(400.0, 800.0)
	
	get_status().start(100, get_health())
	
	
	add_drop(0.7, bomb_scene, 'bomb', 1, 7)
	
	$AnimatedSprite.playing = true
	var mob_types = $AnimatedSprite.frames.get_animation_names()
	$AnimatedSprite.animation = mob_types[randi() % mob_types.size()]
	#print('mob started: ', position)
	$PathTimer.start()
	find_path()

func find_path():
	if target != null and !is_instance_valid(target):
		target = null
	
	if player != null:
		var dist = global_position.distance_to(player.global_position)
		if dist <= max_dist:
			target = player
		elif target == player:
			target = null
		#UserData.log(['Dist to player: ', dist, ', Max Dist: ', max_dist])
	elif target is Player:
		target = null
		
	if target != null:
		var path = navigation.get_simple_path(position, target.global_position, true)
		self.path.points = path
	elif get_status().hungry >= 50:
		if foods.size() > 0:
			var dist = global_position.distance_to(foods[foods.keys()[0]].global_position)
			var closest_food
			for k in foods:
				var food = foods[k]
				var dist_food = global_position.distance_to(food.global_position)
				if dist == -1.0: dist = dist_food
				if dist >= dist_food:
					dist = dist_food
					closest_food = food
			target = closest_food
	
	#UserData.log(['Target: ', target, ', foods: ', foods.size()])
	
	#Sem alvos para movimento
	if target == null:
		if self.path.points.size() == 0:
#			self.path.clear_points()
#			linear_velocity = Vector2(0.0, 0.0)
			#TODO: não mover para caminho invalido, atualmente agua.
			var angle = randf() * 360
			var new_pos = global_position
			new_pos.x += sin(angle) * 100
			new_pos.y += cos(angle) * 100
			self.path.points = navigation.get_simple_path(global_position, new_pos, true)
		

func start(nav, path):
	navigation = nav
	self.path = path

func _process(delta):
	pass

func _physics_process(delta):
	var points = path.points
	for i in range(points.size()):
		var d = position.distance_to(points[i])
		if d > 2:
			var velocity = position.direction_to(points[i]) * (speed + get_status().hungry * 20) * delta
			linear_velocity = velocity
			break
		else:
			path.remove_point(0)
	
func _on_VisibilityNotifier2D_screen_exited():
	#queue_free()
	pass

func _on_Mob_killed():
	path.queue_free()

func _on_PathTimer_timeout():
	find_path()

func _on_ViewArea_body_entered(body):
	if body is Player:
		player = body
		#UserData.log(['New Target: ', body])
	if body is TreeMap:
		var tree_id = body.get_rid().get_id()
		if not tree_id in foods:
			foods[tree_id] = body
			#UserData.log(['New Food to mob: ', tree_id])


#Retornar quantidade alterada...
func time_tick(year_chaged: bool, month_change: bool, day_changed: bool, hour_changed: bool):
	#UserData.log(['Update mob...', get_rid(), ', Hungry: ', hungry])
	if day_changed and get_status().hungry < 50:
		UserData.log(['Create new mob...', get_status().hungry])
		var new_pos = get_global_position()
		var angle = randf() * 360
		new_pos.x += sin(angle) * 50
		new_pos.y += cos(angle) * 50
		
		get_tree().get_current_scene().add_mob(new_pos)
		get_status().hungry += 50
		
	if day_changed:
		get_status().add_age(1)
	pass


func _on_ViewArea_body_exited(body):
	if body is Player:
		player = null
	elif body.get_rid().get_id() in foods:
		foods.erase(body.get_rid().get_id())



# --------------------------------------- DAMAGE ------------------------------ #

func _on_DamageArea_body_entered(body):
	if body == self: return #TODO: verificar ignorar proprio objeto
	if body is DropItem and body is LogDrop:
		get_status().hungry -= body.get_quantity() * 10 #Adicionar variavel
		body.queue_free()
	#UserData.log(['Start damage:', body])
	if body is BaseItem and body.get_type() == 'tree': #Verificar como buscar por pacote.
		damage_targets.append(body)
		return
		
	if body is Player:
		damage_targets.append(body)
	


func _on_DamageArea_body_exited(body):
	damage_targets.erase(body)
	#UserData.log(['Stop damage:', body])

func _on_DamageTimer_timeout():
	if damage_targets.size() == 0: return
	for target in damage_targets:
		if target is BaseItem:
			target.apply_damage(get_damage())
			continue
		if target is Player:
			target.apply_damage(get_damage())

# --------------------------------------- DAMAGE ------------------------------ #
