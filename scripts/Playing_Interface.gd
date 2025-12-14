extends Control

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


func _ready() -> void:
	_refresh_ui()


func _process(_delta: float) -> void:
	_refresh_ui()


# Met à jour toute l'interface depuis GameGlobals
func _refresh_ui() -> void:
	# Informations de progression
	if world_label:
		world_label.text = str(GameGlobals.world)
	if level_label:
		level_label.text = str(GameGlobals.level)
	if run_label:
		run_label.text = str(GameGlobals.run)

	# Barre de vie et détection de mort
	if health_bar:
		health_bar.max_value = GameGlobals.max_health
		var was_alive: bool = health_bar.value > 0
		health_bar.value = GameGlobals.health
		if was_alive and GameGlobals.health <= 0:
			die.emit()

	# Points et expérience
	if power_points_label:
		power_points_label.text = str(GameGlobals.power_points)
	if experience_label:
		experience_label.text = str(GameGlobals.experience)

	# Arme actuelle
	var weapon = GameGlobals.get_current_weapon()
	if not weapon.is_empty():
		if selected_weapon_label:
			selected_weapon_label.text = weapon["name"]
		if weapon_image:
			var image_path = "res://assets/guns/%s" % weapon["image"]
			weapon_image.texture = load(image_path) if ResourceLoader.exists(image_path) else null
		if ammunition_label:
			ammunition_label.text = "%d/%d" % [weapon["ammo"], weapon["max_ammo"]]
