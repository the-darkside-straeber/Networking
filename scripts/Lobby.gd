extends Control

var margin := 100

func _ready() -> void:
	if get_tree().is_network_server():
			$Button.show()
	if Network.has_loaded:
		for player in Network.players:
			placeFrame(Network.players[player].player, player)
	else:
		get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
		if get_tree().is_network_server():
			placeFrame(0, 1)


func _on_network_peer_disconnected(id: int) -> void:
	if id in Network.players:
		yield(Network, "player_disconnected")
	get_node("Frames/"+str(id)).queue_free()
	update_frames()


func update_frames():
	for child in $Frames.get_children():
		if not int(child.name) in Network.players:
			continue
		child.rect_position = Vector2(
			rect_size.x*(Network.players[int(child.name)].player+1)/(Network.players.size()+1),
			180
		)
		child.setVisuals(
			Network.players[int(child.name)].pName,
			"",
			Network.players[int(child.name)].character,
			Network.players[int(child.name)].color
			)


remote func placeFrame(n : int, id: int) -> void:
	var slot : Control = load("res://scenes/PlayerSlot.tscn").instance()
	$Frames.add_child(slot)
	slot.name = str(id)
	slot.setVisuals(Network.players[id].pName, "", Network.players[id].character, Network.players[id].color)
	slot.rect_position = Vector2(-margin+(rect_size.x+2*margin)*(n+1)/(Network.players.size()+1), 180)
	update_frames()
