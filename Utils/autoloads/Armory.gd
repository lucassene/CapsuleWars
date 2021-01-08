extends Node

enum type {
	PRIMARY,
	SECONDARY
}

var weapons = {
	"Pistol": preload("res://Actors/Scenes/Weapons/Pistol.tscn"),
	"Assault Rifle": preload("res://Actors/Scenes/Weapons/AssaultRifle.tscn"),
	"Scout Rifle": preload("res://Actors/Scenes/Weapons/ScoutRifle.tscn"),
	"Pulse Rifle": preload("res://Actors/Scenes/weapons/PulseRifle.tscn"),
	"Sniper Rifle": preload("res://Actors/Scenes/weapons/SniperRifle.tscn"),
	"Remote Pistol": preload("res://Actors/Scenes/Weapons/Remote_Pistol.tscn"),
	"Remote Assault Rifle": preload("res://Actors/Scenes/Weapons/Remote_AssaultRifle.tscn"),
	"Remote Scout Rifle": preload("res://Actors/Scenes/Weapons/Remote_ScoutRifle.tscn"),
	"Remote Pulse Rifle": preload("res://Actors/Scenes/weapons/Remote_PulseRifle.tscn"),
	"Remote Sniper Rifle": preload("res://Actors/Scenes/weapons/Remote_SniperRifle.tscn")
}

var primaries = {
	0: "Assault Rifle",
	1: "Scout Rifle",
	2: "Pulse Rifle",
	3: "Sniper Rifle"
}

var secondaries = {
	0: "Pistol"
}
