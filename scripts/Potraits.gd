extends Control


func _ready() -> void:
	update_portraits()
	get_tree().connect("network_peer_disconnected", self, "_on_network_peer_disconnected")
	Network.connect("display_health", self, "_on_Network_display_health")


func update_portraits() -> void:
	for child in get_children():
		child.name += "o"
		child.queue_free()
	var pos := 0
	for player in Network.players:
		pos += 1
		var portrait: Control = load("res://scenes/Portrait.tscn").instance()
		portrait.name = str(player)
		portrait.get_node("Bar/Name").text = Network.players[player].pName
		portrait.rect_position = Vector2(pos*rect_size.x/(Network.players.size()+1),5)
		portrait.get_node("Character").texture = Match.get_sprite(
			Network.players[player].character,
			Network.players[player].color
		)
		add_child(portrait)


func _on_Network_display_health(id: int, percent: float) -> void:
	get_node(str(id)+"/Bar/Health").value = percent


func _on_network_peer_disconnected(id: int) -> void:
	update_portraits()
