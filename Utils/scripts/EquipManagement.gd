extends Spatial

var weapons = []
var current_weapon
var current_index
var can_swap = true

var player
 
func initialize(actor,items):
	player = actor
	instance_weapons(items)
	current_weapon = weapons[0]
	current_index = 0
	parent_weapon(current_weapon)

func instance_weapons(items):
	print(items)
	for each in items:
		var weapon = Armory.weapons[each].instance()
		weapon.connect("on_stowed",self,"_on_weapon_stowed")
		weapon.connect("on_draw_completed",self,"_on_weapon_draw_completed")
		weapon.set_owner(player)
		player.add_weapon(weapon)
		weapons.append(weapon)
	instance_melee_weapon()

func instance_melee_weapon():
	var melee_weapon = Armory.knife.instance()
	melee_weapon.set_owner(player)
	player.add_melee_weapon(melee_weapon)

func change_loadout(items):
	free_current_loadout()
	instance_weapons(items)
	current_weapon = weapons[0]
	current_index = 0
	parent_weapon(current_weapon)
	current_weapon.draw_weapon()

func free_current_loadout():
	for weapon in weapons:
		weapon.queue_free()
	weapons.clear()

func set_current_weapon(index):
	if current_weapon:
		current_weapon.stow_weapon()
	current_weapon = weapons[index]
	current_index = index

func get_current_weapon():
	return current_weapon

func back_to_primary():
	current_weapon = weapons[0]
	current_index = 0
	return current_weapon

func equip_weapon(index):
	if index != current_index:
		set_current_weapon(index)
		return current_weapon

func swap_weapon():
	if can_swap and current_weapon.can_swap():
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
	to_parent.to_stowed_position()
	add_child(to_parent)

func reload_weapons():
	for weapon in weapons:
		weapon.set_full_magazine(true)

func is_busy():
	return current_weapon.is_busy()

func _on_weapon_stowed(stowed_weapon):
	player.stow_weapon(stowed_weapon)
	parent_weapon(current_weapon)
	current_weapon.draw_weapon()

func _on_weapon_draw_completed():
	can_swap = true
