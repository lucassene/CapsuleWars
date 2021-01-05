extends Node

onready var spawn_manager = $SpawnPoints
onready var lobby_hud = $CanvasLayer/Lobby
onready var main_hud = $CanvasLayer/MainHUD

var spawn_points = []

func _ready():
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	Network.connect("on_server_disconnected",self,"_on_server_disconnected")
	main_hud.connect("on_exit_to_lobby",self,"_on_exit_to_lobby")
	Scores.connect("on_kill_streak",main_hud,"_on_player_kill_streak")
	randomize()
	for each in spawn_manager.get_children():
		spawn_points.append(each)

func create_players_intances():
	var new_player
	var player_spawns = []
	for id in Network.connected_players:
		var player_spawn = {
			id = -1,
			name = "",
			color = 0,
			position = Vector3.ZERO,
			rotation = Vector3.ZERO
		}
		new_player = Global.player_scene.instance()
		new_player.set_name(str(id))
		new_player.set_network_master(id)
		add_child(new_player)
		new_player.set_material(Network.connected_players[id].color)
		new_player.set_hud_name(Network.connected_players[id].name)
		var spawn = spawn_player(new_player)
		player_spawn.id = id
		player_spawn.position = spawn.transform.origin
		player_spawn.rotation = spawn.rotation
		player_spawn.name = Network.connected_players[id].name
		player_spawn.color = Network.connected_players[id].color
		player_spawns.append(player_spawn)
	rpc("receive_player_spawns",player_spawns)

func spawn_player(actor):
	var spawn = null
	while(spawn == null):
		var random = rand_range(0,spawn_points.size()-1)
		spawn = spawn_points[random]
		if !spawn.get_can_spawn():
			spawn = null
	spawn.set_can_spawn(false)
	actor.transform.origin = spawn.transform.origin
	actor.rotation = spawn.rotation
	actor.set_dead_state(false)
	return spawn

remote func receive_player_spawns(player_spawns):
	for item in player_spawns:
		var new_player = Global.player_scene.instance()
		new_player.set_name(str(item.id))
		new_player.set_network_master(item.id)
		new_player.transform.origin = item.position
		new_player.rotation = item.rotation
		add_child(new_player)
		new_player.set_material(item.color)
		new_player.set_hud_name(item.name)
		new_player.set_dead_state(false)
	lobby_hud.hide()

func connect_player_signals(player):
	player.connect("on_player_killed",self,"_on_player_killed")
	player.connect("on_player_killed",main_hud,"_on_player_killed")
	player.connect("on_weapon_equipped",main_hud,"_on_player_weapon_equipped")
	player.connect("on_weapon_changed",main_hud,"_on_player_weapon_changed")
	player.connect("on_shot_fired",main_hud,"_on_player_shot_fired")
	player.connect("on_reload",main_hud,"_on_player_reload")
	player.connect("on_health_changed",main_hud,"_on_player_health_changed")
	player.connect("on_player_death",main_hud,"_on_player_death")
	player.connect("on_player_spawned",main_hud,"_on_player_spawned")
	player.connect("on_menu_pressed",main_hud,"_on_pause_menu_pressed")
	player.connect("on_score_changed",main_hud,"_on_score_changed")

func _on_game_begin():
	get_tree().set_refuse_new_network_connections(true)
	lobby_hud.hide()
	create_players_intances()
	pass

func _on_player_disconnected(player):
	var player_scene = get_node("/root/Game/" + str(player.id))
	player_scene.queue_free()

remotesync func _on_server_disconnected():
	for child in get_children():
		if child.is_in_group("Player"):
			child.queue_free()
	get_tree().network_peer = null
	lobby_hud.reset()

func _on_player_killed(id,is_headshot,_victim_id):
	if is_network_master():
		var player_scene = get_node("/root/Game/" + str(id))
		player_scene.rpc("update_score","kills",1,is_headshot)

func _on_player_can_spawn(actor):
	spawn_player(actor)

func _on_DeathArea_body_entered(body):
	body.set_dead_state(true)

func _on_exit_to_lobby():
	rpc("_on_server_disconnected")
