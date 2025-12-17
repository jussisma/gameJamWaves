extends Entity

# --- Variables de Loot ---
# AJUSTA ESTA RUTA si tu escena no está en la raíz "res://"
const LOOT_SCENE = preload("res://consumable.tscn") 
@export_range(0.0, 1.0) var drop_chance: float = 0.5 # 50% de probabilidad de drop

# --- Variables de Combate ---
@export var speed: float = 80.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var attack_duration: float = 0.5
@export var experience_reward: int = 10 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_timer: Timer = $Timer

var target: Node2D = null
var can_attack: bool = true
var player_in_hurtbox: Node2D = null
var is_attacking: bool = false

func _ready() -> void:
	# Aseguramos la inicialización del padre Entity (vida, etc)
	super._ready() 
	
	add_to_group("enemy")
	attack_timer.wait_time = attack_cooldown
	#attack_timer.timeout.connect(func(): can_attack = true)
	
	attack_timer.one_shot = true # Importante: Que solo se ejecute una vez

	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(_delta: float) -> void: # _delta no se usa, lo marcamos con _
	_deal_continuous_damage()
	
	if target == null or not is_instance_valid(target):
		if not is_attacking: 
			_play_animation("idle")
		return
	
	# Navegación hacia el jugador
	nav_agent.target_position = target.global_position
	
	if not nav_agent.is_navigation_finished():
		var next_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_pos)
		velocity = direction * speed
		
		# Girar el sprite
		if sprite:
			sprite.flip_h = direction.x < 0
		
		if not is_attacking:  
			_play_animation("walk")
	else:
		velocity = Vector2.ZERO
		if not is_attacking:  
			_play_animation("idle")
	
	move_and_slide()

# Llamado cuando el jugador entra en la HurtBox
func _deal_continuous_damage() -> void:
	if player_in_hurtbox and is_instance_valid(player_in_hurtbox):
		# VERIFICACIÓN ROBUSTA: Solo atacamos si el Timer NO está corriendo
		if attack_timer.is_stopped():
			
			# 1. Aplicar daño
			if player_in_hurtbox.has_method("take_damage"):
				player_in_hurtbox.take_damage(attack_damage)
				print("Golpe al jugador! Daño: ", attack_damage) # Debug para consola
			
			# 2. Iniciar el tiempo de espera (Cooldown)
			attack_timer.start()
			
			# 3. Animación
			if not is_attacking:  
				_play_attack_combo()

func _on_hurt_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_hurtbox = body

func _on_hurt_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):        
		player_in_hurtbox = null

func _play_attack_combo() -> void:
	if sprite == null:
		return
	
	is_attacking = true
	
	# Reproducir ataque
	if sprite.sprite_frames.has_animation("attack1"):
		sprite.play("attack1")
		await get_tree().create_timer(attack_duration).timeout
	
	is_attacking = false
	_play_animation("idle")

func _play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)

# --- FUNCIÓN DE MUERTE MODIFICADA ---
func die() -> void:
	# 1. Dar experiencia (Usando GameGlobals como en tu script)
	GameGlobals.experience += experience_reward
	print("Enemy died! XP +", experience_reward)
	
	# 2. DROP DE CONSUMIBLE
	# randf() devuelve un float entre 0.0 y 1.0
	if randf() <= drop_chance:
		spawn_loot()
	
	# 3. Llamar a la función die() del padre (Entity) que hace queue_free()
	super.die()

func spawn_loot() -> void:
	if LOOT_SCENE:
		var loot = LOOT_SCENE.instantiate()
		loot.global_position = global_position
		
		# Llamamos a la función que creamos antes para que sea un tipo al azar
		
		loot.randomize_type()
			
		# Usamos call_deferred para añadirlo al padre de forma segura
		# (Evita errores si se hace justo durante un cálculo de físicas)
		get_parent().call_deferred("add_child", loot)
