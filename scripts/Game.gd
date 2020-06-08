extends Node2D

func _ready():
	get_tree().set_pause(true)
	var peerID = get_tree().get_network_unique_id()
	var localPlayer : KinematicBody2D = preload("res://scenes/Player.tscn").instance()
	localPlayer.name = "Player"+str(peerID)
	localPlayer.set_network_master(peerID)
	localPlayer.position = get_node("Level/Level/Spawnpoint/"+str(Network.self_data.player)).position
	$Players.add_child(localPlayer)
	localPlayer.setup(peerID)
	print(Network.self_data.player)
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
