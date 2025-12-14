extends Node

# State of the game
var is_game_playing: bool = false

# Game State Variables
var world: int = 1
var level: int = 1
var run: int = 1

# Player Stats
var power_points: int = 0
var experience: int = 0
var max_health: float = 100.0
var health: float = 100.0

# Weapon Data
var weapons_data: Dictionary = {}

# Weapons equipped by player
var weapons_equipped: Array = []  # [{name, ammo, max_ammo, image}]
var current_weapon_index: int = 0


func _ready() -> void:
	weapons_data = preload("res://data/weapons_data.gd").WEAPONS.duplicate(true)


# Initialize the game state at launch
func initialize_game(_world: int, _level: int, _run: int, _max_health: float, _weapons: Array[String]) -> void:
	world = _world
	level = _level
	run = _run
	power_points = 0
	experience = 0
	max_health = _max_health
	health = _max_health
	current_weapon_index = 0
	is_game_playing = true

	# Initialize the weapons equipped
	weapons_equipped.clear()
	for weapon_name in _weapons:
		if weapons_data.has(weapon_name):
			var weapon_data = weapons_data[weapon_name]
			weapons_equipped.append({
				"name": weapon_name,
				"ammo": weapon_data["max_ammo"],
				"max_ammo": weapon_data["max_ammo"],
				"image": weapon_data["image"]
			})


# Getters
func get_current_weapon() -> Dictionary:
	if current_weapon_index >= 0 and current_weapon_index < weapons_equipped.size():
		return weapons_equipped[current_weapon_index]
	return {}


func get_current_weapon_name() -> String:
	var weapon = get_current_weapon()
	return weapon.get("name", "")


func get_current_weapon_ammo() -> int:
	var weapon = get_current_weapon()
	return weapon.get("ammo", 0)


# Setters for weapons
func add_ammunition(amount: int) -> void:
	if current_weapon_index < weapons_equipped.size():
		var weapon = weapons_equipped[current_weapon_index]
		weapon["ammo"] = min(weapon["ammo"] + amount, weapon["max_ammo"])


func lose_ammunition(amount: int = 1) -> void:
	if current_weapon_index < weapons_equipped.size():
		var weapon = weapons_equipped[current_weapon_index]
		weapon["ammo"] = max(weapon["ammo"] - amount, 0)


func select_weapon_by_index(index: int) -> void:
	if index >= 0 and index < weapons_equipped.size():
		current_weapon_index = index


# Upgrade a weapon (increase max_ammo for example)
func upgrade_weapon(weapon_name: String, property: String, value) -> void:
	if weapons_data.has(weapon_name):
		weapons_data[weapon_name][property] = value

		# Update the equipped weapon if it is the one being upgraded
		for weapon in weapons_equipped:
			if weapon["name"] == weapon_name and property in weapon:
				weapon[property] = value


func stop_game() -> void:
	is_game_playing = false
