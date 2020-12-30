extends Node

const RPC_PORT = 23571
const MAX_PLAYER = 5
const TESTING_IP = "127.0.0.1"

var self_data = {
	id = -1,
	name = ""
}

var connected_players = {}

signal on_new_peer(id)
signal on_peer_disconnected(info)

func _ready():
	get_tree().connect("network_peer_connected",self,"_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connection_failed",self,"_on_connection_failed")

func create_server(nickname):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(RPC_PORT,MAX_PLAYER)
	get_tree().set_network_peer(peer)
	save_host_info(nickname)

func create_client(nickname, server_ip = TESTING_IP):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip,RPC_PORT)
	get_tree().set_network_peer(peer)
	save_client_info(nickname)

func save_host_info(nickname):
	self_data.name = nickname
	self_data.id = get_tree().get_network_unique_id()
	connected_players[1] = self_data

func save_client_info(nickname):
	self_data.name = nickname
	self_data.id = get_tree().get_network_unique_id()
	connected_players[get_tree().get_network_unique_id()] = self_data

func get_player_info(id):
	return connected_players[id]

remote func receive_player_info(id,info):
	connected_players[id] = info
	if get_tree().is_network_server():
		for player_id in connected_players:
			if player_id != 1:
				var player_data = connected_players[player_id]
				rpc_id(player_id,"receive_player_info",player_id,player_data)
	emit_signal("on_new_peer",id)

remote func receive_server_info(info):
	connected_players[1] = info

remote func send_info_to_server():
	if not get_tree().is_network_server():
		rpc_id(1,"receive_player_info",get_tree().get_network_unique_id(),self_data)

func _on_player_connected(id):
	rpc_id(id,"send_info_to_server")
	if get_tree().is_network_server():
		rpc_id(id,"receive_server_info",self_data)

func _on_player_disconnected(id):
	emit_signal("on_peer_disconnected",connected_players[id])
	connected_players.erase(id)

func _on_connection_failed():
	connected_players.clear()
