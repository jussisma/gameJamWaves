extends Entity

@export var speed: float = 80.0
@export var attack_damage: int = 10
@export var attack_cooldown: float = 1.0
@export var attack_duration: float = 0.5
@export var experience_reward: int = 10  # XP donnée au joueur à la mort 
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var attack_timer: Timer = $Timer

var target: Node2D = null
var can_attack: bool = true
var player_in_hurtbox: Node2D = null
var is_attacking: bool = false

func _ready() -> void:
	add_to_group("enemy")
	attack_timer.wait_time = attack_cooldown
	attack_timer.timeout.connect(func(): can_attack = true)

	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

func _physics_process(delta: float) -> void:
	_deal_continuous_damage()
	
	if target == null or not is_instance_valid(target):
		if not is_attacking: 
			_play_animation("idle")
		return
	
	# Navigation towards the player
	nav_agent.target_position = target.global_position
	
	if not nav_agent.is_navigation_finished():
		var next_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_pos)
		velocity = direction * speed
		
		# Flip the sprite
		if sprite:
			sprite.flip_h = direction.x < 0
		
		if not is_attacking:  
			_play_animation("walk")
	else:
		velocity = Vector2.ZERO
		if not is_attacking:  
			_play_animation("idle")
	
	move_and_slide()

# Called by the HurtBox when the player enters it
func _deal_continuous_damage() -> void:
	if player_in_hurtbox and is_instance_valid(player_in_hurtbox) and can_attack:
		if player_in_hurtbox.has_method("take_damage"):
			player_in_hurtbox.take_damage(attack_damage)
		can_attack = false
		attack_timer.start()
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
	
	# Play attack1
	if sprite.sprite_frames.has_animation("attack1"):
		sprite.play("attack1")
		await get_tree().create_timer(attack_duration).timeout
	
	is_attacking = false
	_play_animation("idle")

func _play_animation(anim_name: String) -> void:
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)

# Override the die() function of Entity
func die() -> void:
	# Give experience to the player
	GameGlobals.experience += experience_reward
	print("Enemy died! Player gained ", experience_reward, " XP. Total: ", GameGlobals.experience)
	
	# Call the parent die() function
	super.die()
