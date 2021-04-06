extends Node

const KILL_SCORE = 100
const SPECIAL_SHOT_KILL_SCORE = 150
const DAMAGE_SCORE = 1
const DEATH_PENALTY = 50
const THREE_STREAK_BONUS = 100
const FIVE_STREAK_BONUS = 200
const TEN_STREAK_BONUS = 500
const FIFTEEN_STREAK_BONUS = 1500
const TWENTY_STREAK_BONUS = 1500
const KILLER_STREAK_BONUS = 25

enum {REGULAR_SHOT,HEADSHOT,TAILSHOT}

var player_scores = {}

var local_score = {
	id = -1,
	name = "",
	score = 0,
	damage = 0,
	kills = 0,
	deaths = 0,
	kd = 1.0,
	shots_fired = 0,
	hits = 0
}

signal on_score_changed(id,item)
signal on_kill_streak(id,kills)

func update_score(id,item,value,shot_type):
	player_scores[id][item] += value
	match item:
		"kills":
			player_scores[id].kill_streak += 1
			add_kill_score(id, value * KILL_SCORE, shot_type)
			update_kd(id)
			return
		"deaths":
			player_scores[id].kill_streak = 0
			update_kd(id)
			return
		"damage":
			add_damage_score(id, value / DAMAGE_SCORE)
			return

func add_kill_score(id, score, shot_type):
	var bonus = 0
	var ks = player_scores[id].kill_streak
	emit_signal("on_kill_streak",id,ks)
	if ks == 3:
		bonus = THREE_STREAK_BONUS
	elif ks == 5:
		bonus = FIVE_STREAK_BONUS
	elif ks == 10:
		bonus = TEN_STREAK_BONUS
	elif ks == 15:
		bonus = FIFTEEN_STREAK_BONUS
	elif ks == 20:
		bonus = TWENTY_STREAK_BONUS
	elif ks > 20:
		bonus = KILLER_STREAK_BONUS
	if shot_type != 0:
		score = SPECIAL_SHOT_KILL_SCORE
	player_scores[id].score += score + bonus
	emit_signal("on_score_changed",id,"score")

func add_damage_score(id,score):
	player_scores[id].score += int(score)
	emit_signal("on_score_changed",id,"score")

func update_kd(id):
	if player_scores[id].deaths == 0:
		player_scores[id].kd = player_scores[id].kills
	else:
		player_scores[id].kd = float(player_scores[id].kills) / float(player_scores[id].deaths)
	emit_signal("on_score_changed",id,"kd")

func clear_scores():
	player_scores.clear()
