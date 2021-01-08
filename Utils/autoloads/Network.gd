extends Node

const MAX_PLAYER = 5
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 23571

var self_data = {
	id = -1,
	name = "",
	color = 0,
	primary = 0
}

var connected_players = {}

signal on_new_peer(id)
signal on_peer_disconnected(info)
signal on_server_disconnected()
signal on_server_created()
signal on_client_created()
signal on_cant_create_server(message)

func _ready():
	get_tree().connect("network_peer_connected",self,"_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connection_failed",self,"_on_connection_failed")
	get_tree().connect("server_disconnected",self,"_on_server_disconnected")

func create_server(nickname,server_port):
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(int(server_port),MAX_PLAYER)
	if error != OK:
		emit_signal("on_cant_create_server",error)
	else:
		get_tree().set_network_peer(peer)
		save_host_info(nickname)
		emit_signal("on_server_created")

func create_client(nickname, server_ip,server_port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip,int(server_port))
	get_tree().set_network_peer(peer)
	save_client_info(nickname)
	emit_signal("on_client_created")

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

func clear_connected_players():
	connected_players.clear()

func _on_player_connected(id):
	rpc_id(id,"send_info_to_server")
	if get_tree().is_network_server():
		rpc_id(id,"receive_server_info",self_data)

func _on_player_disconnected(id):
	emit_signal("on_peer_disconnected",connected_players[id])
	clear_connected_players()

func _on_connection_failed():
	clear_connected_players()

func _on_server_disconnected():
	emit_signal("on_server_disconnected")
	get_tree().network_peer = null
	clear_connected_players()

func _on_game_begin():
	if get_tree().is_network_server():
		get_tree().set_refuse_new_network_connections(true)

func _on_exit_to_lobby():
	if get_tree().is_network_server():
		get_tree().set_refuse_new_network_connections(false)
	clear_connected_players()
