extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var speed: float = 200.0
var last_direction: Vector2 = Vector2(0, 1)

func _physics_process(delta: float) -> void:
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
		last_direction = input_vector
		play_animation("move", input_vector)
	else:
		velocity = Vector2.ZERO
		play_animation("idle", last_direction)

	move_and_slide()

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
