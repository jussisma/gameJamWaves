extends Control

# Import des données d'armes
const WeaponsData = preload("res://data/weapons_data.gd")

# Signals
signal die

# UI References
@onready var world_label: Label = %WorldLabel
@onready var level_label: Label = %LevelLabel
@onready var run_label: Label = %RunLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var power_points_label: Label = %PowerPointsLabel
@onready var experience_label: Label = %ExperienceLabel
@onready var ammunition_label: Label = %AmmunitionLabel
@onready var selected_weapon_label: Label = %SelectedWeaponLabel
@onready var weapon_image: TextureRect = %WeaponImage

# Game State Variables
var world: int:
	set(value):
		world = value
		if world_label:
			world_label.text = str(world)

var level: int:
	set(value):
		level = value
		if level_label:
			level_label.text = str(level)

var run: int:
	set(value):
		run = value
		if run_label:
			run_label.text = str(run)

# Player Stats
var power_points: int:
	set(value):
		power_points = value
		if power_points_label:
			power_points_label.text = str(power_points)

var experience: int:
	set(value):
		experience = value
		if experience_label:
			experience_label.text = str(experience)

var max_health: float:
	set(value):
		max_health = value
		if health_bar:
			health_bar.max_value = max_health

var health: float:
	set(value):
		var was_alive: bool = health > 0
		health = value
		if health_bar:
			health_bar.value = health
		if was_alive and health <= 0:
			die.emit()

# Weapon Stats
var weapons: Array = []  # [{name, ammo, max_ammo, image}]
var current_weapon_index: int:
	set(value):
		if value >= 0 and value < weapons.size():
			current_weapon_index = value
			_update_weapon_ui()


### Initialize the UI
func init_ui(_world: int, _level: int, _run: int, _max_health: float, _weapons_equipped: Array[String]) -> void:
	world = _world
	level = _level
	run = _run
	power_points = 0
	experience = 0
	max_health = _max_health
	health = _max_health
	current_weapon_index = 0

	# Initialize the weapons
	weapons.clear()
	for weapon_name in _weapons_equipped:
		if WeaponsData.WEAPONS.has(weapon_name):
			var weapon_data = WeaponsData.WEAPONS[weapon_name]
			weapons.append({
				"name": weapon_name,
				"ammo": weapon_data["max_ammo"],
				"max_ammo": weapon_data["max_ammo"],
				"image": weapon_data["image"]
			})


### Setters
func add_power_points() -> void:
	power_points += 1

func add_experience(amount: int) -> void:
	experience += amount

func add_health(amount: float) -> void:
	health = min(health + amount, max_health)

func lose_health(amount: float) -> void:
	health = max(health - amount, 0)

func add_ammunition(amount: int) -> void:
	if current_weapon_index < weapons.size():
		var weapon = weapons[current_weapon_index]
		weapon["ammo"] = min(weapon["ammo"] + amount, weapon["max_ammo"])
		_update_weapon_ui()

func lose_ammunition() -> void:
	if current_weapon_index < weapons.size():
		var weapon = weapons[current_weapon_index]
		weapon["ammo"] = max(weapon["ammo"] - 1, 0)
		_update_weapon_ui()

func select_weapon_by_index(index: int) -> void:
	current_weapon_index = index


### Getters
func get_current_weapon() -> Dictionary:
	return weapons[current_weapon_index]["name"]

func get_current_weapon_ammo() -> int:
	return weapons[current_weapon_index]["ammo"]

func get_power_points() -> int:
	return power_points

func get_experience() -> int:
	return experience

func get_health() -> float:
	return health


### Update the weapon UI
func _update_weapon_ui() -> void:
	if current_weapon_index >= weapons.size():
		return

	var weapon = weapons[current_weapon_index]

	if selected_weapon_label:
		selected_weapon_label.text = weapon["name"]

	if weapon_image:
		var image_path = "res://guns/%s" % weapon["image"]
		weapon_image.texture = load(image_path) if ResourceLoader.exists(image_path) else null

	if ammunition_label:
		ammunition_label.text = "%d/%d" % [weapon["ammo"], weapon["max_ammo"]]
