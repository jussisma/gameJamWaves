extends Node
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

@export var enemy_scene: PackedScene
@export var spawn_points: Array[Marker2D] = []
@export var time_between_waves: float = 3.0
@export var time_between_spawns: float = 0.5

# Configuration of the waves : [number of enemies per wave]
@export var waves: Array[int] = [3, 5, 7, 10, 15]

var current_wave: int = 0
var enemies_alive: int = 0
var is_spawning: bool = false

func _ready() -> void:
	# Connect to the enemy group to track the deaths
	await get_tree().process_frame
	start_wave()

func start_wave() -> void:
	if current_wave >= waves.size():
		all_waves_completed.emit()
		print("🎉 All waves completed!")
		return
	
	current_wave += 1
	var enemy_count = waves[current_wave - 1]
	
	print("=== Wave ", current_wave, " started! (", enemy_count, " enemies) ===")
	wave_started.emit(current_wave)
	
	# Update GameGlobals if you want to display the wave number
	if GameGlobals:
		GameGlobals.level = current_wave
	
	is_spawning = true
	await _spawn_enemies(enemy_count)
	is_spawning = false

func _spawn_enemies(count: int) -> void:
	for i in range(count):
		_spawn_single_enemy()
		await get_tree().create_timer(time_between_spawns).timeout

func _spawn_single_enemy() -> void:
	if enemy_scene == null or spawn_points.is_empty():
		push_error("WaveManager: enemy_scene or spawn_points not configured!")
		return
	
	# Choose a random spawn point
	var spawn_point = spawn_points.pick_random()
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	
	# Connect the death signal to track
	enemy.died.connect(_on_enemy_died)
	
	enemies_alive += 1
	get_parent().add_child(enemy)

func _on_enemy_died() -> void:
	enemies_alive -= 1
	print("Enemy died. Remaining: ", enemies_alive)
	
	if enemies_alive <= 0 and not is_spawning:
		_on_wave_cleared()

func _on_wave_cleared() -> void:
	print("=== Wave ", current_wave, " completed! ===")
	wave_completed.emit(current_wave)
	
	# Pause before the next wave
	await get_tree().create_timer(time_between_waves).timeout
	start_wave()