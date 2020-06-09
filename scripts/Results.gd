extends Control

var margin := 100

func _ready():
	for player in Network.players:
		var slot : Control = load("res://scenes/PlayerSlot.tscn").instance()
		add_child(slot)
		slot.name = str(player)
		slot.setVisuals(
			Network.players[player].pName,
			str(Network.players[player].score),
			Network.players[player].character,
			Network.players[player].color
		)
		slot.rect_position = Vector2(
			rect_size.x*(Network.players[player].player+1)/(Network.players.size()+1),
			180
		)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Exit"):
		to_lobby()


func to_lobby() -> void:
	get_tree().change_scene("res://scenes/Lobby.tscn")


func _on_Return_pressed():
	to_lobby()
