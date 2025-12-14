extends Area2D

# Definimos los tipos que coinciden con tus animaciones y lógica
enum Tipo { AMMO, EXP, HEALTH, POWER, MONEY }

# Variables configurables
@export var tipo_actual: Tipo = Tipo.MONEY
@export var cantidad: int = 10 

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	actualizar_animacion()

func actualizar_animacion():
	# Convierte el ENUM a string minúscula (ej: Tipo.AMMO -> "ammo")
	var nombre_animacion = Tipo.keys()[tipo_actual].to_lower()
	
	if animated_sprite.sprite_frames.has_animation(nombre_animacion):
		animated_sprite.play(nombre_animacion)
	else:
		push_warning("Falta la animación: " + nombre_animacion)

func _on_body_entered(body):
	# Verificamos si es el jugador. 
	# Asegúrate de que tu nodo Player esté en el grupo "player"
	if body.is_in_group("player"):
		aplicar_efecto_autoload()
		queue_free()

func aplicar_efecto_autoload():
	match tipo_actual:
		Tipo.MONEY:
			GameManager.money += cantidad
			print("Dinero total: ", GameManager.money)
			
		Tipo.EXP:
			GameManager.experience += cantidad
			print("XP total: ", GameManager.experience)
			
		Tipo.POWER:
			# Mapeado a tu variable 'power_points'
			GameManager.power_points += cantidad
			print("Poder total: ", GameManager.power_points)
			
		Tipo.HEALTH:
			# Lógica para no superar la vida máxima definida en tu Autoload
			if GameManager.health < GameManager.max_health:
				GameManager.health += cantidad
				# Nos aseguramos de no pasarnos del tope
				if GameManager.health > GameManager.max_health:
					GameManager.health = GameManager.max_health
				print("Salud recuperada: ", GameManager.health)
				
		Tipo.AMMO:
			# USAMOS TU FUNCIÓN para recargar el arma actual
			# Así actualiza 'weapons_equipped' correctamente
			GameManager.add_ammunition(cantidad)
			print("Munición añadida al arma actual")

# Función útil para tus spawners/cofres
func aleatorizar_tipo():
	tipo_actual = Tipo.values().pick_random()
	actualizar_animacion()
