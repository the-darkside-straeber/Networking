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
	$Character.rect_position = Vector2(
		rect_size.x*(Network.players[get_tree().get_network_unique_id()].player+1)/(Network.players.size()+1) - $Character.rect_size.x/2,
		350
	)
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


func _on_ColorRight_pressed() -> void:
	for i in range(1,7):
		var count := 0
		for player in Network.players:
			count += 1
			if(Network.players[player].character == Network.players[get_tree().get_network_unique_id()].character and
				Network.players[player].color == int(Network.players[get_tree().get_network_unique_id()].color + i)%6 and
				player != get_tree().get_network_unique_id()):
					break
			if count == Network.players.size():
				rpc("set_color", get_tree().get_network_unique_id(), int(Network.players[get_tree().get_network_unique_id()].color + i)%6)
				return


func _on_ColorLeft_pressed() -> void:
	for i in range(1,7):
		var count := 0
		for player in Network.players:
			count += 1
			if(Network.players[player].character == Network.players[get_tree().get_network_unique_id()].character and
				Network.players[player].color == int(Network.players[get_tree().get_network_unique_id()].color - i+6)%6 and
				player != get_tree().get_network_unique_id()):
					break
			if count == Network.players.size():
				rpc("set_color", get_tree().get_network_unique_id(), int(Network.players[get_tree().get_network_unique_id()].color - i+6)%6)
				return


remotesync func set_color(id: int, color: int) -> void:
	Network.players[id].color = color
	update_frames()
