class_name Entity extends CharacterBody2D

# Variables comunes para TODOS (Jugador y Enemigos)
@export var max_health: int = 100
@onready var current_health: int = max_health

# Señal opcional por si quieres actualizar una barra de vida
signal health_changed(new_health)
signal died

func take_damage(amount: int) -> void:
	current_health -= amount
	print(name + " recibió " + str(amount) + " de daño. Vida: " + str(current_health))
	
	emit_signal("health_changed", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	emit_signal("died")
	queue_free() # Por defecto, el muñeco desaparece. Puedes sobreescribir esto luego.
