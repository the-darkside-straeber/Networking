extends Control

var margin := 100

func _ready():
	for player in Network.players:
		var slot : Control = load("res://scenes/PlayerSlot.tscn").instance()
		add_child(slot)
		slot.name = str(player)
		slot.setVisuals(
			Network.players[player].pName,
			Network.players[player].player,
			str(Network.players[player].score)
		)
		slot.rect_position = Vector2(
			rect_size.x*(Network.players[player].player+1)/(Network.players.size()+1),
			180
		)
