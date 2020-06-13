extends Node2D

const period := 2.0

var gun := ""
var time := .0


func _ready():
	set_gun("")


func _physics_process(delta: float) -> void:
	time += delta
	if time > period:
		time -= period
	$Gun.position.y = -6 + cos(time*2*PI/period)*1.5


remotesync func set_gun(type: String) -> void:
	gun = type
	$Gun.show()
	$Area2D.set_collision_layer_bit(2, true)
	if type != "":
		$Gun.texture = load("res://Assets/Weapons/"+type+".png")
	else:
		$Area2D.set_collision_layer_bit(2, false)
		$Gun.hide()
