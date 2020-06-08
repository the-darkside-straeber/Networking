extends Node2D


func _ready():
	Network.connect("set_main_camera", self, "_on_set_main_camera")


func _on_set_main_camera() -> void:
	$Level/Camera.current = true
