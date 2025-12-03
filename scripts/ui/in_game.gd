extends Control

# Signals
signal die

# Constants
const DEFAULT_MAX_HEALTH: float = 500.0
const DEFAULT_WEAPON: String = "pistol"

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
var world: int = 0:
	set(value):
		world = value
		if world_label:
			world_label.text = str(world)

var level: int = 0:
	set(value):
		level = value
		if level_label:
			level_label.text = str(level)

var run: int = 0:
	set(value):
		run = value
		if run_label:
			run_label.text = str(run)

# Player Stats
var power_points: int = 0:
	set(value):
		power_points = value
		if power_points_label:
			power_points_label.text = str(power_points)

var experience: int = 0:
	set(value):
		experience = value
		if experience_label:
			experience_label.text = str(experience)

var health: float = DEFAULT_MAX_HEALTH:
	set(value):
		var was_alive: bool = health > 0
		health = value
		if health_bar:
			health_bar.value = health
		if was_alive and health <= 0:
			die.emit()

var max_health: float = DEFAULT_MAX_HEALTH:
	set(value):
		max_health = value
		if health_bar:
			health_bar.max_value = max_health

# Weapon Stats
var selected_weapon: String = DEFAULT_WEAPON:
	set(value):
		selected_weapon = value
		if selected_weapon_label:
			selected_weapon_label.text = selected_weapon
		# TODO if weapon_image:
			#weapon_image.image = 

var ammunition: int = 0:
	set(value):
		ammunition = value
		_update_ammunition()

var max_ammunition: int = 0:
	set(value):
		max_ammunition = value
		_update_ammunition()


func init_ui(
	_world: int,
	_level: int,
	_run: int,
	_max_health: float,
	_max_ammunition: int,
	_selected_weapon: String) -> void:
	world = _world
	level = _level
	run = _run
	health = _max_health
	max_health = _max_health
	ammunition = _max_ammunition
	max_ammunition = _max_ammunition
	selected_weapon = _selected_weapon


func take_damage(amount: float) -> void:
	health = max(health - amount, 0)


func _update_all_ui_elements() -> void:
	world_label.text = str(world)
	level_label.text = str(level)
	run_label.text = str(run)
	health_bar.max_value = max_health
	health_bar.value = health
	power_points_label.text = str(power_points)
	experience_label.text = str(experience)
	selected_weapon_label.text = selected_weapon
	_update_ammunition()
	
func _update_ammunition() -> void:
	if ammunition_label:
		ammunition_label.text = str(ammunition) + "/" + str(max_ammunition)
		


func _ready() -> void:
	_update_all_ui_elements()
