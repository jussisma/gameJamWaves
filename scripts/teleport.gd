extends Node2D

signal teleport_started
signal teleport_finished

@export var max_teleport_distance: float = 800.0
@export var teleport_speed: float = 0.15


@onready var player = get_parent()

@onready var ray_cast: RayCast2D = $TeleportRaycast
@onready var cursor: Sprite2D = $Visuals/TeleportCursor
@onready var particles: GPUParticles2D = $Visuals/GPUParticles2D

var is_aiming: bool = false

func _ready() -> void:
	cursor.visible = false
	ray_cast.enabled = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("teleport_aim"):
		start_aiming()
	if Input.is_action_just_released("teleport_aim"):
		stop_aiming()	
	
	if is_aiming:
		aim()
		if Input.is_action_just_pressed("teleport"):
			if GameGlobals.power_points >= 5:
				execute_teleport()
				GameGlobals.power_points = GameGlobals.power_points - 5

func start_aiming() -> void:
	is_aiming = true
	cursor.visible = true
	ray_cast.enabled = true
func stop_aiming() -> void:
	is_aiming = false
	cursor.visible = false
	ray_cast.enabled = false	

func aim() -> void:
	var mouse_pos = get_global_mouse_position()
	var player_pos = player.global_position
	
	var direction = (mouse_pos - player_pos).normalized()
	var distance = player_pos.distance_to(mouse_pos)
	var final_distance = min(distance, max_teleport_distance)
	
	ray_cast.global_position = player_pos 
	ray_cast.target_position = direction * final_distance
	ray_cast.force_raycast_update()
	
	if ray_cast.is_colliding():
		cursor.global_position = ray_cast.get_collision_point()
	else:
		cursor.global_position = player_pos + (direction * final_distance)

func execute_teleport() -> void:
	is_aiming = false
	cursor.visible = false
	ray_cast.enabled = false
	
	var target_pos = cursor.global_position
	
	teleport_started.emit()
	
	particles.global_position = player.global_position
	particles.restart()
	
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(player, "global_position", target_pos, teleport_speed)
	
	tween.tween_callback(func():
		teleport_finished.emit()
	)
