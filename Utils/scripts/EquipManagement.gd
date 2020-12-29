extends Spatial

var weapons = []
var current_weapon
var can_swap = true

func initialize(items):
	for each in items:
		var weapon = Armory.weapons[each].instance()
		weapon.connect("on_stowed",self,"_on_weapon_stowed")
		weapon.connect("on_draw_completed",self,"_on_weapon_draw_completed")
		Global.player.stow_weapon(weapon)
		weapons.append(weapon)
	current_weapon = weapons[0]
	parent_weapon(current_weapon)
	current_weapon.draw_weapon()
	#Global.player.stow_weapon(weapons[1])
	#set_current_weapon(0)

func set_current_weapon(index):
	if current_weapon:
		current_weapon.stow_weapon()
	current_weapon = weapons[index]

func get_current_weapon():
	return current_weapon

func equip_weapon(index):
	set_current_weapon(index)
	return current_weapon

func swap_weapon():
	if can_swap and current_weapon.get_can_swap():
		can_swap = false
		var current = weapons.find(current_weapon)
		if current == 0:
			set_current_weapon(1)
		else:
			set_current_weapon(0)
		return current_weapon
	return null

func parent_weapon(to_parent):
	to_parent.get_parent().remove_child(to_parent)
	add_child(to_parent)

func _on_weapon_stowed(stowed_weapon):
	Global.player.stow_weapon(stowed_weapon)
	parent_weapon(current_weapon)
	current_weapon.draw_weapon()

func _on_weapon_draw_completed():
	can_swap = true
