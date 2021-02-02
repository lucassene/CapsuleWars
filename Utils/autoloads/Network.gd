extends Node

const MAX_PLAYER = 5
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 23571

var self_data = {
	id = -1,
	name = "",
	color = 0,
	primary = 0,
	secondary = 0
}

var connected_players = {}
var used_port = DEFAULT_PORT
var has_mapped_port = false

signal on_new_peer(id)
signal on_peer_disconnected(info)
signal on_server_disconnected()
signal on_server_created()
signal on_client_created()
signal on_cant_create_server(error)
signal on_connected_to_server()

func _ready():
	get_tree().connect("network_peer_connected",self,"_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connection_failed",self,"_on_connection_failed")
	get_tree().connect("server_disconnected",self,"_on_server_disconnected")
	get_tree().connect("connected_to_server",self,"_on_connected_to_server")

func _exit_tree():
	clear_mapped_ports()

func create_server(nickname,server_port,use_upnp):
	used_port = server_port
	if use_upnp: 
		var upnp_error = try_upnp(server_port)
		if upnp_error != UPNP.UPNP_RESULT_SUCCESS:
			emit_signal("on_cant_create_server",upnp_error)
			return
	var peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(int(server_port),MAX_PLAYER)
	if error != OK:
		clear_mapped_ports()
		emit_signal("on_cant_create_server",error)
	else:
		get_tree().set_network_peer(peer)
		save_host_info(nickname)
		emit_signal("on_server_created")

func try_upnp(port):
	var upnp = UPNP.new()
	var error = upnp.discover()
	if error != UPNP.UPNP_RESULT_SUCCESS:
		return error
	error = upnp.add_port_mapping(port,0,"","UDP")
	if error != UPNP.UPNP_RESULT_SUCCESS:
		return error
	error = upnp.add_port_mapping(port,0,"","TCP")
	if error != UPNP.UPNP_RESULT_SUCCESS:
		return error
	has_mapped_port = true
	return UPNP.UPNP_RESULT_SUCCESS

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
	if !is_player_already_connected(id):
		connected_players[id] = info
		emit_signal("on_new_peer",id)

remote func update_player_info(id,info):
	connected_players[id] = info

remote func connect_to_server(peers_info):
	print(peers_info)
	for peer in peers_info:
		connected_players[peer] = peers_info[peer]
		emit_signal("on_new_peer", peer)
	rpc("receive_player_info",get_tree().get_network_unique_id(),self_data)

remote func send_info_to_server():
	if not get_tree().is_network_server():
		rpc_id(1,"update_player_info",get_tree().get_network_unique_id(),self_data)

func clear_connected_players():
	connected_players.clear()

func is_player_already_connected(id):
	for player_id in connected_players:
		if player_id == id:
			return true
	return false

func clear_mapped_ports():
	if has_mapped_port:
		var upnp = UPNP.new()
		upnp.discover()
		upnp.delete_port_mapping(used_port,"UDP")
		upnp.delete_port_mapping(used_port,"TCP")
		has_mapped_port = false

func _on_connected_to_server():
	emit_signal("on_connected_to_server")

func _on_player_connected(id):
	if get_tree().is_network_server():
		rpc_id(id,"connect_to_server",connected_players)

func _on_player_disconnected(id):
	var player = connected_players[id]
	connected_players.erase(id)
	if player: emit_signal("on_peer_disconnected",player)

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
