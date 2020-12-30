class_name Explotion
extends Node2D

const MAX_FORCE := 800
const MIN_FORCE := 300
const MAX_DAMAGE := 40
const MIN_DAMAGE := 30

var hit := []
var ignore : int

func _ready():
	$Particles.emitting = true
	$Particles.lifetime = $Timer.wait_time


func _on_Timer_timeout() -> void:
	queue_free()


func _on_Area_body_entered(body: PhysicsBody2D) -> void:
	if not body.get_network_master() in hit:
		var distance = position.distance_to(body.position)/$Area/Col.shape.radius
		body.knockback(global_position.angle_to_point(body.global_position)+PI, lerp(MAX_FORCE, MIN_FORCE, distance))
		hit.append(body.get_network_master())
		if body.get_network_master() != ignore:
			body.damage(lerp(MAX_DAMAGE, MIN_DAMAGE, distance), ignore)
