extends Entity

# Referencias para configurar en el Inspector
@export var bullet_scene: PackedScene  # <--- Arrastra aquí tu escena de la Bala (.tscn)
@export var bullet_offset: float = 15.0 # <--- Ajusta esto para alejar la bala del cuerpo

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed: float = 200.0
var last_direction: Vector2 = Vector2(0, 1)

func _physics_process(delta: float) -> void:
	# 1. MOVIMIENTO
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
		last_direction = input_vector
		play_animation("move", input_vector)
	else:
		velocity = Vector2.ZERO
		play_animation("idle", last_direction)

	move_and_slide()
	
	# 2. DISPARO
	if Input.is_action_just_pressed("shoot"):
		shoot()

func shoot() -> void:
	if bullet_scene == null:
		return

	var bullet = bullet_scene.instantiate()
	
	# 1. POSICIÓN
	# La colocamos delante del personaje
	bullet.global_position = global_position + (last_direction * bullet_offset)
	
	# 2. ROTACIÓN (¡Aquí está el cambio!)
	# Obtenemos el ángulo del movimiento.
	# Como tu sprite mira hacia ARRIBA, le sumamos 90 grados (PI/2) para compensar.
	bullet.rotation = last_direction.angle() + deg_to_rad(90)
	
	# 3. INSTANCIAR
	get_parent().add_child(bullet)

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
