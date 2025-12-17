extends Entity

# Referencias para configurar en el Inspector
@export var bullet_scene: PackedScene  
const GRENADE_SCENE = preload("res://scenes/GravityGrenade.tscn") 
@export var bullet_offset: float = 15.0 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var teleport: Node2D = $Teleport
@export var pillar_scene: PackedScene = preload("res://scenes/GravityPillar.tscn")

var speed = GameGlobals.speed
var last_direction: Vector2 = Vector2(0, 1)
var is_movement_locked: bool = false

# Variables para el sonido de pasos
var time_since_last_step: float = 0.0
@export var step_interval: float = 0.35 # Tiempo en segundos entre cada paso (ajústalo a la velocidad de tu anim)

func _ready() -> void:
	# 1. ¡IMPORTANTE! Llamar al padre para que configure cosas básicas
	super._ready()
	
	add_to_group("player")
	
	# 2. Seguridad: Si GameGlobals.max_health es 0 o null, pon un valor por defecto
	if GameGlobals.max_health <= 0:
		GameGlobals.max_health = 100.0
		print("¡CUIDADO! GameGlobals.max_health era 0. Se forzó a 100.")
	
	# Sincronizar vida
	max_health = GameGlobals.max_health
	current_health = GameGlobals.health
	
	# Si entras al nivel con 0 de vida, reseteala (para pruebas)
	if current_health <= 0:
		current_health = max_health
		GameGlobals.health = current_health

	if teleport:
		teleport.teleport_started.connect(_on_teleport_started)
		teleport.teleport_finished.connect(_on_teleport_finished)
	
	# DEBUG: Imprimir con cuánta vida empezamos
	print("Player listo. Vida inicial: ", current_health, "/", max_health)

func _physics_process(delta: float) -> void:
	if is_movement_locked:
		return
		
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
		last_direction = input_vector
		play_animation("move", input_vector)
	else:
		velocity = Vector2.ZERO
		play_animation("idle", last_direction)
	
	if velocity.length() > 0: # ¿Nos estamos moviendo?
		time_since_last_step -= delta
		
		if time_since_last_step <= 0:
			# Reproducir sonido
			# Usamos pitch aleatorio (0.8 a 1.2) para que no suene robótico siempre igual
			AudioManager.play_sfx("move", randf_range(0.8, 1.2))
			
			# Reiniciar el contador
			time_since_last_step = step_interval
	else:
		# Si paramos, reseteamos para que el siguiente paso suene inmeditamente al arrancar
		time_since_last_step = 0
	
	move_and_slide() 
	
	if Input.is_action_just_pressed("gravity_grenade"):
		if GameGlobals.power_points >= 20:
			throw_gravity_grenade()
			GameGlobals.power_points = GameGlobals.power_points - 20	

	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	if Input.is_action_just_pressed("place_pillar"):
		if GameGlobals.power_points >= 15:
			place_gravity_pillar()	
			GameGlobals.power_points = GameGlobals.power_points - 15
func shoot() -> void:
	if bullet_scene == null:
		print("Błąd: Nie przypisano bullet_scene w Inspektorze gracza!")
		return

	# 1. COMPROBAR MUNICIÓN
	# Solo disparamos si la munición en GameGlobals es mayor a 0
	if GameGlobals.get_current_weapon_ammo() > 0:
		
		# 2. RESTAR MUNICIÓN
		GameGlobals.lose_ammunition(1)
		print("Disparo realizado. Munición restante: ", GameGlobals.ammo)
		
		# --- Lógica de instanciación original ---
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + (last_direction * bullet_offset)
		bullet.rotation = last_direction.angle() + deg_to_rad(90)
		get_parent().add_child(bullet,1)
		AudioManager.play_sfx("shoot")
	else:
		# 3. FEEDBACK SI NO HAY BALAS (Sonido de "click" o mensaje)
		print("¡Click! Sin munición.")
		# Aquí podrías poner un sonido: $EmptyAmmoSound.play()

func throw_gravity_grenade():
	var grenade = GRENADE_SCENE.instantiate()
	
	get_parent().add_child(grenade)
	
	grenade.setup(global_position, get_global_mouse_position())		
	

func play_animation(action: String, dir_vector: Vector2) -> void:
	var dir = dir_vector.round()
	var anim_name = ""
	
	if dir.y < 0:
		anim_name += "up"
	elif dir.y > 0:
		anim_name += "down"
		
	if dir.x > 0:
		if anim_name != "":
			anim_name += "Right"
		else:
			anim_name = "right"
	elif dir.x < 0:
		if anim_name != "":
			anim_name += "Left"
		else:
			anim_name = "left"
			
	sprite.play(action + "_" + anim_name)
	
func _on_teleport_started() -> void:
	is_movement_locked = true

func _on_teleport_finished() -> void:
	is_movement_locked = false
	
func place_gravity_pillar() -> void:
	if pillar_scene == null:
		print("Błąd: Nie przypisano pillar_scene w Inspektorze!")
		return
		
	var pillar = pillar_scene.instantiate()
	#pillar.global_position = global_position
	

	pillar.global_position = global_position + (last_direction * 60.0)
	
	get_parent().add_child(pillar)

var is_invincible: bool = false
# Override take_damage to sync with GameGlobals for UI
func take_damage(amount: float) -> void:
	# 1. EL MURO: Si ya soy invencible, NO ejecuto nada más.
	if is_invincible:
		return
	
	# 2. ACTIVAR INVENCIBILIDAD PRIMERO
	# Antes de restar vida, cerramos la puerta para que nadie más entre en este frame
	is_invincible = true
	
	# 3. APLICAR DAÑO (Llamar al padre)
	super.take_damage(amount)
	
	# 4. ACTUALIZAR GLOBALES Y UI
	GameGlobals.health = current_health
	print("Auch! Vida restante: ", current_health) # Debug para ver si baja de 10 en 10
	
	# 5. FEEDBACK VISUAL
	modulate = Color(1, 0, 0) # Rojo
	
	# 6. ESPERAR (Cooldown de invencibilidad)
	await get_tree().create_timer(1.0).timeout # Aumenté a 1.0s para probar
	
	# 7. DESACTIVAR INVENCIBILIDAD
	modulate = Color(1, 1, 1) # Blanco
	is_invincible = false
