extends Node2D
class_name Bullet

var vel := Vector2.ZERO setget _set_vel
var lifetime := .0

var time := 0.0
var ignore := 0
var force := 0
var damage := 0
var type := "Bullet"


func _ready() -> void:
	$Sprite.texture = load("res://Assets/Bullets/"+type+".png")


func _physics_process(delta: float) -> void:
	time += delta
	if time > lifetime:
		queue_free()
	position += vel*delta


func _set_vel(val: Vector2) -> void:
	vel = val
	rotation = vel.angle()


func _on_Collider_body_entered(body: PhysicsBody2D) -> void:
	if body.get_collision_layer_bit(0):
		if type == "Shell":
			Match.rpc("make_explotion", position, ignore)
		queue_free()
	if body.get_collision_layer_bit(1) and body.get_network_master() != ignore:
		queue_free()
		body.knockback(rotation, force)
		body.damage(damage, ignore)

