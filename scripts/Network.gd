extends Node

const SERVER_PORT = 31400
const MAX_PLAYERS = 5

signal display_health(id, percent)
signal set_main_camera
signal player_disconnected

var players = {}
var self_data= {pName = "", player = -1, score = 1, dead = false, character = 0, color = 0}
var slots := 0
var mode := 0
var has_loaded := false

func getNewPlayer() -> Vector2:
	slots += 1
	for i in range(6):
		var count = 0
		for player in players:
			count += 1
			if players[player].character == 0 and i == players[player].color:
				break
			if count == players.size():
				return Vector2(slots, i)
	return Vector2(slots, 0)


func _ready():
	get_tree().connect("network_peer_disconnected", self, "on_network_peer_disconnected")
	get_tree().connect("network_peer_connected", self, "on_network_peer_connected")
	get_tree().connect("connected_to_server", self, "on_connected_to_server")
	get_tree().connect("server_disconnected", self, "on_server_disconnected")


func on_server_disconnected() -> void:
	get_tree().change_scene("res://scenes/Menu.tscn")


func on_network_peer_connected(id: int) -> void:
	if get_tree().is_network_server():
		rpc_id(id, "getPlayerNum", getNewPlayer())

remote func getPlayerNum(n : Vector2)-> void:
	#get_tree().root.get_node("Lobby").player = n
	self_data.player = n.x
	self_data.color = n.y
	rpc("SendPlayerData", get_tree().get_network_unique_id(), self_data)

func on_network_peer_disconnected(id: int):
	if get_tree().is_network_server():
		slots -= 1
	for player in players:
		if players[player].player > players[id].player:
			players[player].player -= 1
	players.erase(id)
	emit_signal("player_disconnected")

func JoinServer(ip: String) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, SERVER_PORT)
	get_tree().set_network_peer(peer)

func on_connected_to_server() -> void:
	players[get_tree().get_network_unique_id()] = self_data
	get_tree().change_scene("res://scenes/Lobby.tscn")


func CreateServer() -> void:
	self_data.player = 0
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	get_tree().change_scene("res://scenes/Lobby.tscn")

remote func SendPlayerData(id: int, data: Dictionary) -> void:
	players[id] = data
	if get_tree().get_network_unique_id() == 1:
		for peerId in players:
			rpc_id(id, "SendPlayerData", peerId, players[peerId])
	get_tree().root.get_node("Lobby").placeFrame(data.player, id)

remotesync func GameSetup() -> void:
	for player in players:
		players[player].dead = false
	has_loaded = true
	Match.alive = players.size()
	get_tree().change_scene("res://scenes/Game.tscn")

var playersDone = []

remotesync func Preconfigured() -> void:
	var id = get_tree().get_rpc_sender_id()
	assert(get_tree().is_network_server())
	assert(id in players)
	assert(not id in playersDone)
	
	playersDone.append(id)
	
	if playersDone.size() == players.size():
		rpc("PostConfigureGame")


remotesync func PostConfigureGame() -> void:
	get_tree().set_pause(false)

