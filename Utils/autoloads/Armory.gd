extends Node

enum type {
	PRIMARY,
	SECONDARY
}

var weapons = {
	"Pistol": preload("res://Actors/Scenes/Pistol.tscn"),
	"Assault Rifle": preload("res://Actors/Scenes/AssaultRifle.tscn"),
	"Remote Pistol": preload("res://Actors/Scenes/Remote_Pistol.tscn"),
	"Remote Assault Rifle": preload("res://Actors/Scenes/Remote_AssaultRifle.tscn"),
}
