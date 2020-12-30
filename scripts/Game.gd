extends Node2D


func _ready():
	Network.connect("game_begun", self, "_on_Network_game_begun")
	#start game
	get_tree().set_pause(true)
	#Spawn local player
	var peerID = get_tree().get_network_unique_id()
	var localPlayer : KinematicBody2D = preload("res://scenes/Player.tscn").instance()
	localPlayer.name = "Player"+str(peerID)
	localPlayer.set_network_master(peerID)
	localPlayer.position = get_node("Level/Level/Spawnpoint/"+str(Network.self_data.player)).position
	$Players.add_child(localPlayer)
	localPlayer.setup(peerID)
	#spawn players
	for p in Network.players:
		if p == peerID:
			continue
		var player = preload("res://scenes/Player.tscn").instance()
		player.set_name("Player"+str(p))
		player.set_network_master(p)
		player.position = get_node("Level/Level/Spawnpoint/"+str(Network.players[p].player)).position
		$Players.add_child(player)
		player.setup(p)
	Network.rpc_id(1, "Preconfigured")


func _on_Network_game_begun() -> void:
	#spawn guns
	if get_tree().is_network_server():
		randomize()
		$Timer.start()
		for i in range(min(get_node("Level/Level/Guns").get_child_count(), Network.players.size()+1)):
			var slot := randi()%get_node("Level/Level/Guns").get_child_count()
			while get_node("Level/Level/Guns/"+str(slot)).gun != "":
				slot = (slot+1) % get_node("Level/Level/Guns").get_child_count()
			get_node("Level/Level/Guns/"+str(slot)).rpc("set_gun", Gun.GUNS.keys()[randi()%Gun.GUNS.size()])


func _on_Timer_timeout():
	get_node("Level/Level/Guns/"+str(randi()%get_node("Level/Level/Guns").get_child_count())).rpc( 
		"set_gun",
		Gun.GUNS.keys()[randi()%Gun.GUNS.size()]
	)
