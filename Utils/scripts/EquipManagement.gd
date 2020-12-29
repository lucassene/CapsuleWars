extends Spatial

var weapons = []
var current_weapon

func initialize(items):
	for each in items:
		var weapon = Armory.weapons[each].instance()
		weapon.set_visible(false)
		add_child(weapon)
		weapons.append(weapon)
	set_current_weapon(0)

func set_current_weapon(index):
	if current_weapon: current_weapon.set_visible(false)
	weapons[index].set_visible(true)
	current_weapon = weapons[index]

func get_current_weapon():
	return current_weapon

func equip_weapon(index):
	set_current_weapon(index)
	return current_weapon

func swap_weapon():
	var current = weapons.find(current_weapon)
	if current == 0:
		set_current_weapon(1)
	else:
		set_current_weapon(0)
	return current_weapon
