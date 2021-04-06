extends Node

onready var knife = preload("res://Actors/Scenes/weapons/MeleeWeapon.tscn")

enum type {
	PRIMARY,
	SECONDARY
}

var weapons = {
	"Pistol": preload("res://Actors/Scenes/weapons/Pistol.tscn"),
	"SMG": preload("res://Actors/Scenes/weapons/SMG.tscn"),
	"Assault Rifle": preload("res://Actors/Scenes/weapons/AssaultRifle.tscn"),
	"Scout Rifle": preload("res://Actors/Scenes/weapons/ScoutRifle.tscn"),
	"Pulse Rifle": preload("res://Actors/Scenes/weapons/PulseRifle.tscn"),
	"Sniper Rifle": preload("res://Actors/Scenes/weapons/SniperRifle.tscn"),
}

var primaries = {
	0: "Assault Rifle",
	1: "Scout Rifle",
	2: "Pulse Rifle",
	3: "Sniper Rifle"
}

var secondaries = {
	0: "Pistol",
	1: "SMG"
}

