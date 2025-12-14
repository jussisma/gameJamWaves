extends Node2D

func _ready() -> void:
	var selected_weapons: Array[String] = ["Glock P80", "Revolver Colt 45", "AK47", "Bazooka M20"]
	GameGlobals.initialize_game(1, 1, 1, 500, selected_weapons)

# Input handling for testing
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_L:
			if GameGlobals.weapons_equipped.size() > 0:
				# Mettre à jour le max_ammo de l'arme à l'index 0
				GameGlobals.weapons_equipped[0]["max_ammo"] = 100
				# Remplir les munitions au maximum
				GameGlobals.weapons_equipped[0]["ammo"] = 100
