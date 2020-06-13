extends Node2D

#Shotgun
const Shotgun := {
	type = "Bullets",
	spread = .3,
	speed = 450,
	speed_spread = 100,
	bullets = 6,
	lifetime = .2,
	recoil = 15000,
	delay = .7,
	capacity =  3,
	reload_time = 1.5,
	knockback = 3000,
	damage = 10,
	mags = 7,
	point = Vector2(7.5,-1.5)
}

const Handgun := {
	type = "Bullets",
	spread = .03,
	speed = 700,
	speed_spread = 10,
	bullets = 1,
	lifetime = .5,
	recoil = 1000,
	delay = .3,
	capacity =  10,
	reload_time = 1.2,
	knockback = 4000,
	damage = 20,
	mags = 3,
	point = Vector2(7.5,-1.5)
}


var ammo := 0
var mags := 0
var mode := "" setget _set_mode
var gun : Dictionary
var can_shoot := true


func _ready():
	_set_mode("")


func shoot() -> int:
	if mode == "":
		return -1
	if gun.type == "Bullets" && can_shoot:
		for i in range(gun.bullets):
			Match.rpc("make_bullet",
				$Rotation/Point.global_position,
				rotation + (randf()*2-1)*gun.spread,
				gun.speed + (randf()*2-1)*gun.speed_spread,
				gun.lifetime,
				get_tree().get_network_unique_id(),
				gun.knockback,
				gun.damage
			)
		can_shoot = false
		ammo -= 1
		if ammo == 0:
			if mags == 0:
				_set_mode("")
				can_shoot = true
				return gun.recoil
			ammo = gun.capacity
			$Tween.interpolate_property(
				$Rotation,
				"rotation",
				0,
				2*PI*floor(gun.reload_time/.4),
				gun.reload_time,
				Tween.TRANS_BACK,
				Tween.EASE_OUT
			)
			mags -= 1
		else:
			var rot = (PI/8)*(int($Rotation/Sprite.flip_v)*2-1)
			$Tween.interpolate_property(
				$Rotation,
				"rotation",
				0,
				rot,
				gun.delay,
				Tween.TRANS_BACK,
				Tween.EASE_OUT
			)
			$Tween.interpolate_property(
				$Rotation,
				"rotation",
				rot,
				0,
				gun.delay,
				Tween.TRANS_BACK,
				Tween.EASE_OUT
			)
		$Tween.start()
		return gun.recoil
	
	return 0


func _set_mode(val: String) -> void:
	mode = val
	if val != "":
		$Rotation/Sprite.texture = load("res://Assets/Weapons/"+val+".png")
	var visibility = true
	if mode == "":
		visibility = false
	else:
		gun = get(mode)
		ammo = gun.capacity
		mags = gun.mags
		$Rotation/Point.position = gun.point
	rpc("set_visible", visibility)


remotesync func set_visible(val: bool) -> void:
	visible = val


func _on_Tween_tween_all_completed() -> void:
	can_shoot = true
