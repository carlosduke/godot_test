class_name Weapon
extends Area2D

export(int) var damage
#TODO: tipos de dano

func set_damage(_damage):
	damage = _damage

func get_damage():
	return damage
