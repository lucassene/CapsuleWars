extends Control

onready var score_scene = preload("res://interface/scenes/PlayerScores.tscn")
onready var score_container = $MainContainer/BoardContainer/MarginContainer/ScoreContainer

func _ready():
	Scores.connect("on_score_changed",self,"_on_score_changed")

func initialize():
	for id in Network.connected_players:
		rpc("create_player_score",id)

remotesync func create_player_score(player_id):
	var player = Network.connected_players[player_id]
	var player_score = {
		id = player_id,
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
	score.set_name(str(player.id))
	score_container.add_child(score)
	score.set_player_id(player.id)
	score.initialize()

func update_score(id,item):
	var scene = get_node("MainContainer/BoardContainer/MarginContainer/ScoreContainer/" + str(Scores.player_scores[id].id))
	update_order(id)
	scene.update_item(item)

func update_order(player_id):
	var player_scene = get_node("MainContainer/BoardContainer/MarginContainer/ScoreContainer/" + str(player_id))
	for id in Scores.player_scores:
		if id != player_id and Scores.player_scores[player_id].score > Scores.player_scores[id].score:
			var compare_scene = get_node("MainContainer/BoardContainer/MarginContainer/ScoreContainer/" + str(id))
			if player_scene.get_index() > compare_scene.get_index():
				score_container.move_child(player_scene,compare_scene.get_index())

func remove_player_score(id):
	for player in score_container.get_children():
		if player.name == str(id):
			player.queue_free()

func clear_player_score():
	for player in score_container.get_children():
		if player.is_in_group("PlayerScore"):
			player.queue_free()

func create_score_control(player_id,player_score):
	var score_control = {
		id = player_id,
		score = player_score
	}
	return score_control

func _on_score_changed(id,item):
	update_score(id,item)
