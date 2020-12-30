extends KinematicBody2D

export var damp := .5
export var speed := 240
export var grav := 800
export var jumpGrav := 600
export var kyoteJump := .15
export var jumpTime := .32
export var jumpStrength := 360
export var acceleration := 1000
export var max_health := 100
export var max_speed := 30000

var groundTimer : float = 0
var onGround : bool = false
var jumpTimer : float = 0
var jumpMode : int = -1
var vel : Vector2 = Vector2.ZERO
var moveX : int = 0
var has_gun := true


onready var last_damage_from := get_tree().get_network_unique_id()
onready var health := max_health

puppet var slavehealth := 0 setget _set_slavehealth
puppet var slavePosition
puppet var slaveVel = Vector2.ZERO
puppet var gun_rotation := 0.0


func setup(id) -> void:
	slavehealth = max_health
	slavePosition = position
	$Sprite.texture = Match.get_sprite(Network.players[id].character, Network.players[id].color)
	if id == get_tree().get_network_unique_id():
		$Camera2D.current = true


func _set_slavehealth(val: int):
	slavehealth = val
	Network.emit_signal("display_health", get_network_master(), float(slavehealth)*100/max_health)


remotesync func die() -> void:
	if Network.players[get_network_master()].dead:
		return
	hide()
	set_physics_process(false)
	set_process_unhandled_input(false)
	Network.players[get_network_master()].score += Network.players.size() - Match.alive
	Network.players[get_network_master()].dead = true
	Match.alive -= 1
	if is_network_master():
		Network.emit_signal("set_main_camera")


func damage(damage: int, source_id: int) -> void:
	if source_id != -1:
		last_damage_from = source_id
	if not is_network_master():
		return
	health -= damage
	health = max(0,health)
	if health == 0:
		rpc("die")
	Network.emit_signal("display_health", get_tree().get_network_unique_id(), float(health)*100/max_health)
	rset("slavehealth", health)


func knockback(rotation: float, force: int) -> void:
	vel.y += sin(rotation)*force
	vel.x += cos(rotation)*force


func _unhandled_input(event: InputEvent) -> void:
	if is_network_master():
		var recoil_force := -22
		if event.is_action_pressed("Fire"):
			recoil_force = $Gun.shoot()
			if sin($Gun.rotation) >= 0 and vel.y < 0:
				vel.y = 0
			knockback($Gun.rotation, -max(0,recoil_force))
		if event.is_action_pressed("pickup_item") or recoil_force == -1:
			for area in $ItemDetect.get_overlapping_areas():
				if area.get_collision_layer_bit(2):
					var item_holder = area.get_parent()
					$Gun.mode = item_holder.gun
					item_holder.rpc("set_gun", "")


func _physics_process(delta: float)-> void:
	if is_network_master():
		if position.y > 1000:
			damage(health, -1)
		if jumpMode == 1:
			vel.y += jumpGrav*delta
		else:
			vel.y += grav*delta
		vel.y = min(vel.y,max_speed)
		moveX = 0
		moveX = Input.get_action_strength("MoveRight")-Input.get_action_strength("MoveLeft")
		CalJump(delta)
		vel.x = cal_x_velocity(vel.x, moveX*speed, acceleration, delta)
		vel = move_and_slide(vel, Vector2(0,-1))
		rset("slaveVel", vel)
		rset_unreliable("slavePosition", position)
		if has_gun:
			var angle: float = $Gun.position.angle_to(get_local_mouse_position()) - PI/2
			$Gun.rotation = angle
			$Gun/Rotation/Sprite.flip_v = angle < -PI/2
			rset_unreliable("gun_rotation", $Gun.rotation+($Gun/Rotation.rotation if has_node("Gun/Rotation") else 0))
	else:
		position = slavePosition
		slaveVel = move_and_slide(slaveVel, Vector2(0,-1))
		if has_gun:
			$Gun.rotation = gun_rotation
			$Gun/Rotation/Sprite.flip_v = gun_rotation > PI/2

func CalJump(delta : float)-> void:
	#ground detection
	onGround = false
	if is_on_floor():
		groundTimer = 0
		onGround = true
	if groundTimer > kyoteJump:
		groundTimer = -1
	elif groundTimer != -1:
		onGround = true
	#jump timing
	if jumpMode == -1 && Input.is_action_just_pressed("Jump"):
		setJump(0)
	if jumpMode == 0:
		if Input.is_action_just_released("Jump"):
			setJump(-1)
		if jumpTimer >= kyoteJump:
			setJump(-1)
		if onGround:
			groundTimer = -1
			setJump(1)
			vel.y = -jumpStrength
	if jumpMode == 1:
		if jumpTimer > jumpTime or Input.is_action_just_released("Jump"):
			setJump(-1)
	#timer
	if groundTimer != -1:
		groundTimer += delta
	if jumpMode != -1:
		jumpTimer += delta


func setJump(mode: int)-> void:
	jumpMode = mode
	jumpTimer = min(0,mode)


func cal_x_velocity(current_x: float, goal: float, acc: float, delta: float) -> float:
	var res := current_x + sign(goal-current_x)*acc*delta
	if sign(goal-res) != sign(goal-current_x):
		res = goal
	return res
