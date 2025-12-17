extends Area2D

enum Tipo { AMMO, EXP, HEALTH, POWER, MONEY }

@export var tipo_actual: Tipo = Tipo.MONEY
@export var cantidad: int = 10 
var player_ref: Node2D = null

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	# Cuando el objeto entra al juego, lee el tipo y pone la animación
	update_animation()
	player_ref = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	# 1. Sprawdzamy warunki wstępne:
	# - Czy mamy referencję do gracza?
	# - Czy gracz odblokował magnes w sklepie?
	if not player_ref or not GameGlobals.magnet_unlocked:
		return

	# 2. Obliczamy odległość do gracza
	var distance = global_position.distance_to(player_ref.global_position)

	# 3. Jeśli gracz jest w zasięgu magnesu -> PRZYCIĄGANIE
	if distance < GameGlobals.magnet_range:
		# Lerp daje efekt płynnego przyspieszania im bliżej celu jesteśmy
		# 'delta * GameGlobals.magnet_speed' to siła przyciągania
		global_position = global_position.lerp(player_ref.global_position, delta * GameGlobals.magnet_speed)	

func update_animation():
	if not animated_sprite: return # Protección por si acaso
	
	var nombre_animacion = Tipo.keys()[tipo_actual].to_lower()
	
	if animated_sprite.sprite_frames.has_animation(nombre_animacion):
		animated_sprite.play(nombre_animacion)
	else:
		push_warning("Falta la animación: " + nombre_animacion)

func _on_body_entered(body):
	if body.is_in_group("player"):
		apply_effect()
		queue_free()

func apply_effect():
	match tipo_actual:
		Tipo.MONEY:
			GameGlobals.money += cantidad
			# print("Dinero total: ", GameGlobals.money)
		Tipo.EXP:
			GameGlobals.experience += cantidad
		Tipo.POWER:
			GameGlobals.power_points += cantidad
		Tipo.HEALTH:
			if GameGlobals.health < GameGlobals.max_health:
				GameGlobals.health += cantidad
				if GameGlobals.health > GameGlobals.max_health:
					GameGlobals.health = GameGlobals.max_health
		Tipo.AMMO:
			GameGlobals.add_ammunition(cantidad)

# --- CORRECCIÓN AQUÍ ---
func randomize_type():
	# Solo cambiamos el dato. No forzamos la animación aquí.
	# La animación se actualizará automáticamente cuando se ejecute _ready()
	#tipo_actual = Tipo.values().pick_random()
	tipo_actual = Tipo.MONEY
