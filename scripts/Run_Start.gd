extends Node2D

func _ready() -> void:
	var selected_weapons: Array[String] = ["Glock P80", "Revolver Colt 45", "AK47", "Bazooka M20"]
	GameGlobals.initialize_game(1, 1, 1, 500, selected_weapons)
