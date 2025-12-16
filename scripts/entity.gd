class_name Entity extends CharacterBody2D

# Variables comunes
# Usamos float para coincidir con el GameManager
@export var max_health: float = 100.0 
var current_health: float

signal health_changed(new_health)
signal died

func _ready() -> void:
	# LÓGICA DE INICIALIZACIÓN DIFERENCIADA
	if is_in_group("player"):
		# Si soy el jugador, ignoro el valor del Inspector y cargo del GameManager
		max_health = GameGlobals.max_health
		current_health = GameGlobals.health
	else:
		# Si soy un enemigo, uso la vida que le puse en el Inspector
		current_health = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	
	# SINCRONIZACIÓN CON GAMEMANAGER
	if is_in_group("player"):
		GameGlobals.health = current_health
		print("Jugador recibió daño. Vida restante: ", GameGlobals.health)
	else:
		print(name + " (Enemigo) recibió daño. Vida: " + str(current_health))
	
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	emit_signal("died")
	
	if is_in_group("player"):
		# Lógica de Game Over
		print("¡El jugador ha muerto!")
		GameGlobals.stop_game()
		# Aquí podrías llamar a una pantalla de 'Game Over' o pausar el juego
		# queue_free() NO se suele usar en el jugador para no romper la cámara
	else:
		# Si es enemigo, drop de items (opcional) y desaparecer
		queue_free()

# Opcional: Función para curar que también sincronice
func heal(amount: float) -> void:
	current_health += amount
	
	if current_health > max_health:
		current_health = max_health
		
	if is_in_group("player"):
		GameGlobals.health = current_health
		
	emit_signal("health_changed", current_health)
