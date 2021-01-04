extends Node

const KILL_SCORE = 100
const DAMAGE_SCORE = 2

var player_scores = {}

var local_score = {
	name = "",
	score = 0,
	damage = 0,
	kills = 0,
	deaths = 0,
	kd = 1.0
}

signal on_score_changed(id,item)

func update_score(id,item,value):
	print(player_scores[id])
	player_scores[id][item] += value
	match item:
		"kills":
			add_score(id, value * KILL_SCORE)
			update_kd(id)
			return
		"deaths":
			update_kd(id)
			return
		"damage":
			add_score(id, value / DAMAGE_SCORE)
			return

func add_score(id,score):
	player_scores[id].score += score
	emit_signal("on_score_changed",id,"score")

func update_kd(id):
	if player_scores[id].deaths == 0:
		player_scores[id].kd = player_scores[id].kills
	else:
		player_scores[id].kd = float(player_scores[id].kills / player_scores[id].deaths)
	print(player_scores[id].kd)
	emit_signal("on_score_changed",id,"kd")
