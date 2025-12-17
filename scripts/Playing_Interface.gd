extends Control

# Signals
signal die

# UI elements
@onready var health_bar: TextureProgressBar = %HealthBar
@onready var percentage_label: Label = %PercentageLabel
@onready var power_points_label: Label = %PowerPointsLabel
@onready var experience_label: Label = %ExperienceLabel
@onready var ammunition_label: Label = %AmmunitionLabel
@onready var selected_weapon_label: Label = %SelectedWeaponLabel
@onready var weapon_image: TextureRect = %WeaponImage
@onready var minimap_camera: Camera2D = $TopRight/SubViewportContainer/SubViewport/Camera
@onready var minimap_viewport: SubViewport = $TopRight/SubViewportContainer/SubViewport

func _ready() -> void:
	# Configure minimap to share the same 2D world as the main game
	if minimap_viewport:
		minimap_viewport.world_2d = get_viewport().world_2d
	_refresh_ui()

func _process(_delta: float) -> void:
	_refresh_ui()

func _physics_process(_delta: float) -> void:
	# Update minimap camera position to follow player
	if GameGlobals.player:
		minimap_camera.global_position = GameGlobals.player.global_position

# Input handling
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		_handle_weapon_selection(event)


func _handle_weapon_selection(event: InputEventKey) -> void:
	var weapon_index = -1
	if event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_9:
		weapon_index = event.physical_keycode - KEY_1
	elif event.physical_keycode >= KEY_KP_1 and event.physical_keycode <= KEY_KP_9:
		weapon_index = event.physical_keycode - KEY_KP_1
	if weapon_index >= 0 and weapon_index < GameGlobals.weapons_equipped.size():
		GameGlobals.select_weapon_by_index(weapon_index)


# Refresh the UI
func _refresh_ui() -> void:
	# Health bar and death detection
	if health_bar:
		health_bar.max_value = GameGlobals.max_health
		var was_alive: bool = health_bar.value > 0
		health_bar.value = GameGlobals.health
		if percentage_label:
			var percentage = int((GameGlobals.health / GameGlobals.max_health) * 100)
			percentage_label.text = "%d%%" % percentage
		if was_alive and GameGlobals.health <= 0:
			die.emit()

	# Power points and experience
	if power_points_label:
		power_points_label.text = str(GameGlobals.power_points)
	if experience_label:
		experience_label.text = str(GameGlobals.experience)

	# Current weapon
	var weapon = GameGlobals.get_current_weapon()
	if not weapon.is_empty():
		if selected_weapon_label:
			selected_weapon_label.text = weapon["name"]
		if weapon_image:
			var image_path = "res://assets/guns/%s" % weapon["image"]
			weapon_image.texture = load(image_path) if ResourceLoader.exists(image_path) else null
		if ammunition_label:
			ammunition_label.text = "%d/%d" % [weapon["ammo"], weapon["max_ammo"]]
