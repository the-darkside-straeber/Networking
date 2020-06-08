extends Node2D

#Shotgun
const shotgun_spread := 0.3
const shotgun_speed := 450
const shotgun_speed_spread := 100
const shotgun_bullets := 6
const shotgun_lifetime := .2
const shotgun_recoil := 15000
const shotgun_delay := .7
const shotgun_capacity := 3
const shotgun_reload_time := 1.5
const shotgun_knockback := 3000
const shotgun_damage := 2

var ammo := 0
var mode := "" setget _set_mode
var can_shoot := true


func _ready():
	_set_mode("Shotgun")


func shoot() -> int:
	if mode == "Shotgun" && can_shoot:
		for i in range(shotgun_bullets):
			Match.rpc("make_bullet",
				$Rotation/Point.global_position,
				rotation + (randf()*2-1)*shotgun_spread,
				shotgun_speed + (randf()*2-1)*shotgun_speed_spread,
				shotgun_lifetime,
				get_tree().get_network_unique_id(),
				shotgun_knockback,
				shotgun_damage
			)
		can_shoot = false
		ammo -= 1
		if ammo == 0:
			ammo = shotgun_capacity
			$Tween.interpolate_property(
				$Rotation,
				"rotation",
				0,
				2*PI*floor(shotgun_reload_time/.4),
				shotgun_reload_time,
				Tween.TRANS_BACK,
				Tween.EASE_OUT
			)
		else:
			var rot = (PI/8)*(int($Rotation/Sprite.flip_v)*2-1)
			$Tween.interpolate_property(
				$Rotation,
				"rotation",
				0,
				rot,
				shotgun_delay,
				Tween.TRANS_BACK,
				Tween.EASE_OUT
			)
			$Tween.interpolate_property(
				$Rotation,
				"rotation",
				rot,
				0,
				shotgun_delay,
				Tween.TRANS_BACK,
				Tween.EASE_OUT
			)
		$Tween.start()
		return shotgun_recoil
	
	return 0


func _set_mode(val: String) -> void:
	mode = val
	$Rotation/Sprite.show()
	if mode == "Shotgun":
		ammo = shotgun_capacity
	else:
		$Rotation/Sprite.hide()


func _on_Tween_tween_all_completed() -> void:
	can_shoot = true
