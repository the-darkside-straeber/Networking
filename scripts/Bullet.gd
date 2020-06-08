extends Node2D
class_name Bullet

var speed := 0
var lifetime := .0

var time := 0.0
var ignore := 0
var force := 0
var damage := 0


func _physics_process(delta: float) -> void:
	time += delta
	if time > lifetime:
		queue_free()
	position += Vector2(cos(rotation),sin(rotation))*speed*delta


func _on_Collider_body_entered(body: PhysicsBody2D) -> void:
	if body.get_collision_layer_bit(0):
		queue_free()
	if body.get_collision_layer_bit(1) and body.get_network_master() != ignore:
		queue_free()
		body.knockback(rotation, force)
		body.damage(damage, ignore)

