extends Node
class_name WaveManager

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed

@export var enemy_scene: PackedScene
@export var spawn_points: Array[Marker2D] = []
@export var time_between_waves: float = 3.0
@export var time_between_spawns: float = 0.5

@export var waves: Array[int] = [3, 5, 7, 10, 15]

var current_wave: int = 0
var enemies_alive: int = 0
var is_spawning: bool = false
var last_spawn_index: int = 0 # CORRECCIÓN 1: Variable para rotar puntos

func _ready() -> void:
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
	
	if get_node_or_null("/root/GameGlobals"): # Pequeña protección por si no existe
		get_node("/root/GameGlobals").level = current_wave
	
	is_spawning = true
	await _spawn_enemies(enemy_count)
	is_spawning = false

func _spawn_enemies(count: int) -> void:
	for i in range(count):
		_spawn_single_enemy()
		await get_tree().create_timer(time_between_spawns).timeout

# --- AQUÍ ESTÁN LOS CAMBIOS IMPORTANTES ---
func _spawn_single_enemy() -> void:
	if enemy_scene == null or spawn_points.is_empty():
		push_error("WaveManager: Configura la escena o los puntos!")
		return
	
	# CORRECCIÓN 1: Usar rotación en vez de random para evitar superposiciones
	var valid_spawn_points = spawn_points.filter(func(p): return p != null)
	if valid_spawn_points.is_empty(): return

	# Avanzamos al siguiente punto de la lista
	last_spawn_index = (last_spawn_index + 1) % valid_spawn_points.size()
	var spawn_point = valid_spawn_points[last_spawn_index]
	
	var enemy = enemy_scene.instantiate()
	enemy.global_position = spawn_point.global_position
	
	# CORRECCIÓN 2: Decirle al enemigo quién es el jugador
	# Asumimos que el enemigo tiene una variable llamada 'target' o 'player'
	var player = get_tree().get_first_node_in_group("player")
	if player:
		# Intenta asignar el target si el script del enemigo tiene esa variable
		if "target" in enemy:
			enemy.target = player
		elif "player" in enemy:
			enemy.player = player
	
	# Conectar señal de muerte
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)
	else:
		push_error("El enemigo no tiene señal 'died'!!")
	
	enemies_alive += 1
	get_parent().add_child(enemy)

func _on_enemy_died() -> void:
	enemies_alive -= 1
	# print("Enemy died. Remaining: ", enemies_alive)
	
	if enemies_alive <= 0 and not is_spawning:
		_on_wave_cleared()

func _on_wave_cleared() -> void:
	print("=== Wave ", current_wave, " completed! ===")
	wave_completed.emit(current_wave)
	await get_tree().create_timer(time_between_waves).timeout
	start_wave()
