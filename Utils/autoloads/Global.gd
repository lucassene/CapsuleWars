extends Node

var player_scene = preload("res://Actors/Scenes/Player.tscn")

var color_materials = {
	"black" : "res://assets/materials/player-black.tres",
	"blue" : "res://assets/materials/player-blue.tres",
	"gray" :"res://assets/materials/player-gray.tres",
	"green" :"res://assets/materials/player-green.tres",
	"purple" : "res://assets/materials/player-pink.tres",
	"red" : "res://assets/materials/player-red.tres",
	"white" : "res://assets/materials/player-white.tres",
	"yellow" : "res://assets/materials/player-yellow.tres"
}

var player
