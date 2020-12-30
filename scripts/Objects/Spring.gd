extends Area2D


func jump_body(body: Node) -> void:
	body.vel = -body.vel.reflect(transform.y)
	var length = body.vel.length()
	if 0 < length and length < 600:
		body.vel *= min(2, 600/body.vel.length())


func _on_Spring_area_entered(area: Area2D):
	if area.get_parent().is_in_group("Bounce"):
		jump_body(area.get_parent())


func _on_Spring_body_entered(body: PhysicsBody2D):
	if body.is_in_group("Bounce"):
		jump_body(body)
