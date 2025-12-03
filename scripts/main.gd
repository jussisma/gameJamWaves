extends Node2D

@onready var ui: Control = $InGameUI

func _ready() -> void:
	var selected_weapons: Array[String] = ["Glock P80", "Revolver Colt 45", "AK47", "Bazooka M20"]
	ui.init_ui(1, 1, 1, 500, selected_weapons)
	ui.die.connect(_on_ui_die)

func _on_ui_die():
	print("i die")

# Tests
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.physical_keycode:
			KEY_A:
				ui.add_power_points()
				print("Power Points : +1")

			KEY_B:
				ui.lose_health(10)
				print("Health : -10")

			KEY_C:
				ui.add_health(20)
				print("Health : +20")

			KEY_D:
				ui.lose_ammunition()
				print("Ammunition : -1")

			KEY_E:
				ui.add_experience(10)
				print("Experience : +10")

			KEY_1, KEY_KP_1:
				ui.select_weapon_by_index(0)

			KEY_2, KEY_KP_2:
				ui.select_weapon_by_index(1)

			KEY_3, KEY_KP_3:
				ui.select_weapon_by_index(2)

			KEY_4, KEY_KP_4:
				ui.select_weapon_by_index(3)

			KEY_5, KEY_KP_5:
				ui.select_weapon_by_index(4)
