extends Node

onready var spawn_manager = $SpawnPoints
onready var lobby_hud = $CanvasLayer/Lobby
onready var main_hud = $CanvasLayer/MainHUD
onready var players_container = $Players
onready var music_player_a = $MusicPlayerA
onready var music_player_b = $MusicPlayerB
onready var fade_in_tween = $FadeInTween
onready var fade_out_tween = $FadeOutTween
onready var spawn_container = $SpawnPoints
onready var kill_sound_player = $KillSoundPlayer

var client_ready_count = 0
var last_spawn_point
var is_in_lobby = true
var stream_to_be_played
var server_spawn_index = 0

func _ready():
	play_music(Mixer.lobby_music)
	Network.connect("on_peer_disconnected",self,"_on_player_disconnected")
	Network.connect("on_server_disconnected",self,"_on_server_disconnected")
	main_hud.connect("on_exit_to_lobby",self,"_on_exit_to_lobby")
	Scores.connect("on_kill_streak",main_hud,"_on_player_kill_streak")

func create_players_intances():
	var new_player
	var player_spawns = []
	for id in Network.connected_players:
		var player_spawn = {
			id = -1,
			name = "",
			color = 0,
			primary = 0,
			secondary = 0,
			spawn_index = -1
		}
		new_player = Global.player_scene.instance()
		new_player.set_name(str(id))
		new_player.set_network_master(id)
		new_player.set_weapons(Network.connected_players[id].primary,Network.connected_players[id].secondary)
		players_container.add_child(new_player)
		new_player.set_material(Network.connected_players[id].color)
		new_player.set_hud_name(Network.connected_players[id].name)
		var spawn_index = spawn_player(new_player)
		new_player.set_last_spawn(spawn_container.get_child(spawn_index))
		if id == 1: server_spawn_index = spawn_index
		player_spawn.id = id
		player_spawn.spawn_index = spawn_index
		player_spawn.name = Network.connected_players[id].name
		player_spawn.color = Network.connected_players[id].color
		player_spawn.primary = Network.connected_players[id].primary
		player_spawn.secondary = Network.connected_players[id].secondary
		player_spawns.append(player_spawn)
	if Network.connected_players.size() == 1:
		activate_player(1,server_spawn_index)
		start_game()
	else:
		rpc("receive_player_spawns",player_spawns)

func spawn_player(actor):
	randomize()
	var spawn = null
	var spawn_points = spawn_container.get_children()
	var try_count = 0
	while(spawn == null):
		var random = rand_range(0,spawn_points.size())
		spawn = spawn_points[random]
		if try_count <= 10:
			try_count += 1
			if !spawn.get_can_spawn() or spawn == actor.get_last_spawn():
				spawn = null
	spawn.set_can_spawn(false)
	return spawn.get_index()

remotesync func activate_player(id,spawn_index):
	var spawn = spawn_container.get_child(spawn_index)
	var actor = get_player_by_id(id)
	if actor:
		spawn.set_can_spawn(false)
		actor.set_last_spawn(spawn)
		actor.global_transform.origin = spawn.global_transform.origin
		actor.rotation = spawn.rotation
		actor.set_dead_state(false)

func get_player_by_id(id):
	for child in players_container.get_children():
		if child.name == str(id):
			return child
	return null

remotesync func receive_player_spawns(player_spawns):
	if get_tree().is_network_server():
		activate_player(1,server_spawn_index)
	else:
		for item in player_spawns:
			var new_player = Global.player_scene.instance()
			new_player.set_name(str(item.id))
			new_player.set_network_master(item.id)
			new_player.set_weapons(item.primary,item.secondary)
			players_container.add_child(new_player)
			activate_player(item.id,item.spawn_index)
			new_player.set_material(item.color)
			new_player.set_hud_name(item.name)
		rpc_id(1,"on_client_ready")

remote func on_client_ready():
	client_ready_count += 1
	print(str(get_tree().get_rpc_sender_id()) + " is ready!")
	if client_ready_count == Network.connected_players.size() - 1:
		rpc("start_game")
		client_ready_count = 0

remotesync func start_game():
	for player in players_container.get_children():
		player.initialize()
	is_in_lobby = false
	play_music(Mixer.action_music)
	lobby_hud.hide()

func play_music(stream):
	if music_player_a.playing:
		fade_out(music_player_a)
		stream_to_be_played = stream
	elif music_player_b.playing:
		fade_out(music_player_b)
		stream_to_be_played = stream
	else:
		fade_in(music_player_a,stream)

func fade_in(player,stream):
	player.set_stream(stream)
	player.play(0.0)
	fade_in_tween.interpolate_property(player,"volume_db",-30,-15,3.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	fade_in_tween.start()

func fade_out(player):
	fade_out_tween.interpolate_property(player,"volume_db",-12,-80,2.0,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)
	fade_out_tween.start()
	
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
	create_players_intances()
	pass

func _on_player_disconnected(player):
	var player_scene = get_node("/root/Game/Players/" + str(player.id))
	if player_scene:
		Scores.player_scores.erase(player.id)
		player_scene.queue_free()

remotesync func _on_server_disconnected():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Scores.clear_scores()
	for child in players_container.get_children():
		if child.is_in_group("Player"):
			child.queue_free()
	is_in_lobby = true
	play_music(Mixer.lobby_music)

func _on_player_killed(id,shot_type,_victim_id):
	if is_network_master():
		var player_scene = get_node("/root/Game/Players/" + str(id))
		kill_sound_player.play()
		player_scene.rpc("update_score","kills",1,shot_type)

func _on_player_can_spawn(actor):
	var spawn_index = spawn_player(actor)
	rpc("activate_player",actor.name,spawn_index)

func _on_DeathArea_body_entered(body):
	body.set_dead_state(true)

func _on_exit_to_lobby():
	Scores.clear_scores()
	rpc("_on_server_disconnected")
	get_tree().network_peer = null

func _on_FadeOutTween_tween_completed(object,_key):
	object.stop()
	if object == music_player_a:
		fade_in(music_player_b,stream_to_be_played)
	else:
		fade_in(music_player_a,stream_to_be_played)
