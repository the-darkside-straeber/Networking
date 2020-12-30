class_name Gun
extends Node2D

const GUNS := {
	Shotgun = {
		type = "Bullets",
		bullet_type = "Bullet",
		spread = .3,
		speed = 450,
		speed_spread = 100,
		bullets = 6,
		lifetime = .2,
		recoil = 300,
		delay = .7,
		capacity =  3,
		reload_time = 1.5,
		knockback = 300,
		damage = 10,
		mags = 7,
		point = Vector2(7.5,-1.5)
	},
	Handgun = {
		type = "Bullets",
		bullet_type = "Bullet",
		spread = .03,
		speed = 700,
		speed_spread = 10,
		bullets = 1,
		lifetime = .5,
		recoil = 80,
		delay = .3,
		capacity =  10,
		reload_time = 1.2,
		knockback = 400,
		damage = 20,
		mags = 3,
		point = Vector2(7.5,-1.5)
	},
	Bazooka = {
		type = "Bullets",
		bullet_type = "Shell",
		spread = .03,
		speed = 600,
		speed_spread = 5,
		bullets = 1,
		lifetime = .5,
		recoil = .230,
		delay = .3,
		capacity = 1,
		reload_time = 1.5,
		knockback = 1200,
		damage = 20,
		mags = 3,
		point = Vector2(17,-1.5)
	},
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
	if can_shoot:
		match gun.type:
			"Bullets":
				for i in range(gun.bullets):
					Match.rpc("make_bullet",
						$Rotation/Point.global_position,
						rotation + (randf()*2-1)*gun.spread,
						gun.speed + (randf()*2-1)*gun.speed_spread,
						gun.lifetime,
						get_tree().get_network_unique_id(),
						gun.knockback,
						gun.damage,
						gun.bullet_type
					)
				can_shoot = false
				ammo -= 1
				var recoil = gun.recoil
				_reload()
				return recoil
	
	return 0


func _reload() -> void:
	if ammo == 0:
		if mags == 0:
			_set_mode("")
			can_shoot = true
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


func _set_mode(val: String) -> void:
	mode = val
	if mode != "":
		gun = GUNS[mode]
		ammo = gun.capacity
		mags = gun.mags
		$Rotation/Point.position = gun.point
	rpc("_set_visible", mode != "", val)


remotesync func _set_visible(val: bool, sprite: String) -> void:
	visible = val
	if sprite != "":
		$Rotation/Sprite.texture = load("res://Assets/Weapons/"+sprite+".png")


func _on_Tween_tween_all_completed() -> void:
	can_shoot = true
