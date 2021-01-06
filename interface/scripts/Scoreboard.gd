extends Control

onready var score_scene = preload("res://interface/scenes/PlayerScores.tscn")
onready var score_container = $MainContainer/BoardContainer/MarginContainer/ScoreContainer

func _ready():
	Scores.connect("on_score_changed",self,"_on_score_changed")

func initialize():
	for id in Network.connected_players:
		rpc("create_player_score",id)

remotesync func create_player_score(id):
	var player = Network.connected_players[id]
	var player_score = {
		name = player.name,
		score = 0,
		damage = 0,
		kills = 0,
		deaths = 0,
		kd = 0.0,
		kill_streak = 0
	}
	Scores.player_scores[player.id] = player_score
	var score = score_scene.instance()
	score.set_name(player.name)
	score_container.add_child(score)
	score.set_player_id(player.id)
	score.initialize()

func update_score(id,item):
	var scene = get_node("MainContainer/BoardContainer/MarginContainer/ScoreContainer/" + Scores.player_scores[id].name)
	scene.update_item(item)

func _on_score_changed(id,item):
	update_score(id,item)

func remove_player_score(id):
	for player in score_container.get_children():
		if player.name == str(id):
			player.queue_free()

func clear_player_score():
	for player in score_container.get_children():
		if player.is_in_group("PlayerScore"):
			player.queue_free()
