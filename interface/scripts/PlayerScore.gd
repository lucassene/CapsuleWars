extends MarginContainer

onready var name_label = $Container/PlayerName
onready var score_label = $Container/PlayerScore
onready var damage_label = $Container/PlayerDamage
onready var kills_label = $Container/PlayerKills
onready var deaths_label = $Container/PlayerDeaths
onready var kd_label = $Container/PlayerKD

var player_id setget set_player_id

func set_player_id(value):
	player_id = value

func initialize():
	update_labels()

func update_labels():
	update_name()
	update_score()
	update_damage()
	update_kills()
	update_deaths()
	update_kd()

func update_item(item):
	var method = "update_" + item
	call_deferred(method)

func update_name():
	var color = Network.connected_players[player_id].color
	name_label.bbcode_text = "[color=%s]%s[/color]" % [color,Scores.player_scores[player_id].name]

func update_score():
	score_label.text = str(Scores.player_scores[player_id].score)

func update_damage():
	damage_label.text = str(int(Scores.player_scores[player_id].damage))

func update_kills():
	kills_label.text = str(Scores.player_scores[player_id].kills)

func update_deaths():
	deaths_label.text = str(Scores.player_scores[player_id].deaths)

func update_kd():
	kd_label.text = str(stepify(Scores.player_scores[player_id].kd,0.01))


