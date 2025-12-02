extends Control

# Signals
signal die

# Constants
const DEFAULT_HEALTH: float = 400.0
const DEFAULT_MAX_HEALTH: float = 500.0
const DEFAULT_WEAPON: String = "pistol"
const MIN_HEALTH: float = 0.0

# UI References
@onready var world_label: Label = %WorldLabel
@onready var level_label: Label = %LevelLabel
@onready var run_label: Label = %RunLabel
@onready var health_bar: ProgressBar = %HealthBar
@onready var power_points_label: Label = %PowerPointsLabel
@onready var experience_label: Label = %ExperienceLabel
@onready var ammunition_label: Label = %AmmunitionLabel
@onready var max_ammunition_label: Label = %MaxAmmunitionLabel
@onready var selected_weapon_label: Label = %SelectedWeaponLabel

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

var health: float = DEFAULT_HEALTH:
	set(value):
		var was_alive: bool = health > MIN_HEALTH
		health = value
		if health_bar:
			health_bar.value = health
		if was_alive and health <= MIN_HEALTH:
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

var ammunition: int = 0:
	set(value):
		ammunition = value
		if ammunition_label:
			ammunition_label.text = str(ammunition)

var max_ammunition: int = 0:
	set(value):
		max_ammunition = value
		if max_ammunition_label:
			max_ammunition_label.text = str(max_ammunition)


func _ready() -> void:
	_update_all_ui_elements()


func init_ui(
	_world: int,
	_level: int,
	_run: int,
	_health: float,
	_max_health: float,
	_power_points: int,
	_experience: int,
	_ammunition: int,
	_max_ammunition: int,
	_selected_weapon: String) -> void:
	world = _world
	level = _level
	run = _run
	health = _health
	max_health = _max_health
	power_points = _power_points
	experience = _experience
	ammunition = _ammunition
	max_ammunition = _max_ammunition
	selected_weapon = _selected_weapon


func take_damage(amount: float) -> void:
	health = max(health - amount, MIN_HEALTH)


func _update_all_ui_elements() -> void:
	world_label.text = str(world)
	level_label.text = str(level)
	run_label.text = str(run)
	health_bar.max_value = max_health
	health_bar.value = health
	power_points_label.text = str(power_points)
	experience_label.text = str(experience)
	ammunition_label.text = str(ammunition)
	max_ammunition_label.text = str(max_ammunition)
	selected_weapon_label.text = selected_weapon
