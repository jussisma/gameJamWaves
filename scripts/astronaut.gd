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

func _ready() -> void:
	add_to_group("player")
	if teleport:
		teleport.teleport_started.connect(_on_teleport_started)
		teleport.teleport_finished.connect(_on_teleport_finished)

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

	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = global_position + (last_direction * bullet_offset)

	bullet.rotation = last_direction.angle() + deg_to_rad(90)
	
	get_parent().add_child(bullet)

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
