extends Node

onready var spawn_manager = $SpawnPoints
onready var lobby_hud = $CanvasLayer/Lobby
onready var main_hud = $CanvasLayer/MainHUD

var spawn_points = []

func _ready():
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	randomize()
	for each in spawn_manager.get_children():
		spawn_points.append(each)

func create_players_intances():
	var new_player
	var player_spawns = []
	for id in Network.connected_players:
		var player_spawn = {
			id = -1,
			position = Vector3.ZERO
		}
		new_player = Global.player_scene.instance()
		new_player.set_name(str(id))
		new_player.set_network_master(id)
		add_child(new_player)
		player_spawn.id = id
		player_spawn.position = spawn_player(new_player)
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
	actor.set_dead_state(false)
	return spawn.transform.origin

remote func receive_player_spawns(player_spawns):
	for item in player_spawns:
		var new_player = Global.player_scene.instance()
		new_player.set_name(str(item.id))
		new_player.set_network_master(item.id)
		new_player.transform.origin = item.position
		add_child(new_player)
		new_player.set_dead_state(false)
	lobby_hud.hide()

func connect_player_signals(player):
	player.connect("on_weapon_equipped",main_hud,"_on_player_weapon_equipped")
	player.connect("on_weapon_changed",main_hud,"_on_player_weapon_changed")
	player.connect("on_shot_fired",main_hud,"_on_player_shot_fired")
	player.connect("on_reload",main_hud,"_on_player_reload")
	player.connect("on_damage_suffered",main_hud,"_on_player_damage_suffered")
	player.connect("on_player_death",main_hud,"_on_player_death")
	player.connect("on_player_spawned",main_hud,"_on_player_spawned")
	player.connect("on_menu_pressed",main_hud,"_on_pause_menu_pressed")

func _on_game_begin():
	lobby_hud.hide()
	create_players_intances()
	pass

func _on_player_disconnected(player):
	var player_scene = get_node("/root/Game/" + str(player.id))
	player_scene.queue_free()

func _on_player_can_spawn(actor):
	spawn_player(actor)

func _on_DeathArea_body_entered(body):
	body.set_dead_state(true)
