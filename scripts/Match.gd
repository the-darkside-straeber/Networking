extends Node

var alive := 0 setget _set_alive
var bullet_reasource := preload("res://scenes/Bullet.tscn")


func _set_alive(val: int) -> void:
	alive = val
	if alive == 1 and get_tree().is_network_server():
		rpc("to_result")


remotesync func to_result():
	get_tree().change_scene("res://scenes/Results.tscn")


remotesync func make_bullet(
	position: Vector2,
	rotation: float,
	speed: int, lifetime: float,
	ignore: int,
	force: int,
	damage: int
) -> void:
	var bullet : Bullet = bullet_reasource.instance()
	bullet.position = position
	bullet.rotation = rotation
	bullet.speed = speed
	bullet.lifetime = lifetime
	bullet.ignore= ignore
	bullet.force = force
	bullet.damage = damage
	get_tree().root.get_node("GM/Bullets").add_child(bullet)
