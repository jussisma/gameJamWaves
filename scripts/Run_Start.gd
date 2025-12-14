extends Node2D

func _ready() -> void:
	var selected_weapons: Array[String] = ["Glock P80", "Revolver Colt 45", "AK47", "Bazooka M20"]
	GameGlobals.initialize_game(1, 1, 1, 500, selected_weapons)

# Input handling
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_handle_weapon_selection(event)
		_handle_weapon_ammo_upgrade(event)

func _handle_weapon_selection(event: InputEventKey) -> void:
	var weapon_index = -1
	if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_9:
		weapon_index = event.physical_keycode - KEY_1
	elif event.physical_keycode >= KEY_KP_1 and event.physical_keycode <= KEY_KP_9:
		weapon_index = event.physical_keycode - KEY_KP_1
	if weapon_index >= 0 and weapon_index < GameGlobals.weapons_equipped.size():
		GameGlobals.select_weapon_by_index(weapon_index)

# Test for weapon ammunition upgrade
func _handle_weapon_ammo_upgrade(event: InputEventKey) -> void:
	# Upgrade weapon 0 ammunition to 100
	if event.physical_keycode == KEY_L:
		if GameGlobals.weapons_equipped.size() > 0:
			# Mettre à jour le max_ammo de l'arme à l'index 0
			GameGlobals.weapons_equipped[0]["max_ammo"] = 100
			# Remplir les munitions au maximum
			GameGlobals.weapons_equipped[0]["ammo"] = 100
