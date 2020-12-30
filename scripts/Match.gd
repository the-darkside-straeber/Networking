extends Node

const CHARACTERS := ["Default"]
const GUNS := ["Shotgun", "Handgun", "Bazooka"]

var alive := 0 setget _set_alive
var bullet_reasource := preload("res://scenes/Bullet.tscn")
var explotion_reasource := preload("res://scenes/Explotion.tscn")


func get_sprite(character: int, color: int) -> Resource:
	return load("res://Assets/Player/Sprites/"+CHARACTERS[character]+"/"+str(color+1)+".png")


func _set_alive(val: int) -> void:
	alive = val
	if alive == 1:
		for player in Network.players:
			if !Network.players[player].dead:
				Network.players[player].score += Network.players.size()-1
		if get_tree().is_network_server():
			rpc("to_result")


remotesync func to_result():
	get_tree().change_scene("res://scenes/Results.tscn")


remotesync func make_bullet(
	position: Vector2,
	rotation: float,
	speed: int, lifetime: float,
	ignore: int,
	force: int,
	damage: int,
	type: String
) -> void:
	var bullet : Bullet = bullet_reasource.instance()
	bullet.position = position
	#bullet.rotation = rotation
	bullet.vel = Vector2(cos(rotation),sin(rotation))*speed
	bullet.lifetime = lifetime
	bullet.ignore = ignore
	bullet.force = force
	bullet.damage = damage
	bullet.type = type
	if get_tree().root.has_node("GM/Bullets"):
		get_tree().root.get_node("GM/Bullets").add_child(bullet)


remotesync func make_explotion(position: Vector2, ignore: int) -> void:
	var explotion : Explotion = explotion_reasource.instance()
	explotion.ignore = ignore
	explotion.position = position
	if get_tree().root.has_node("GM/Bullets"):
		get_tree().root.get_node("GM/Bullets").call_deferred("add_child", explotion)
