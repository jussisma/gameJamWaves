extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
const PARTICLES = preload("res://particula.tscn")
var particles = PARTICLES.instantiate()
var direction:Vector2 = Vector2(1,0)
var is_moving:bool = false
var speed:float = 200.0

func _process(delta: float) -> void:
	if not is_moving:
		if direction.x == 0:
			if direction.y == 1:
				sprite.play("idleUp")
			if direction.y == -1:
				sprite.play("idleDown")
		if direction.y == 0:
			if direction.x == 1:
				sprite.play("idleRight")
			if direction.x == -1:
				sprite.play("idleLeft")
	if is_moving:
		if direction.x == 0:
			if direction.y == 1:
				sprite.play("moveUp")
			if direction.y == -1:
				sprite.play("moveDown")
		if direction.y == 0:
			if direction.x == 1:
				sprite.play("moveRight")
			if direction.x == -1:
				sprite.play("moveLeft")
		
func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	if Input.is_action_pressed("move_down"):
		direction = Vector2(0,-1)
		velocity = speed*Vector2.DOWN
		is_moving = true
	elif Input.is_action_pressed("move_left"):
		direction = Vector2(-1,0)
		velocity = speed*Vector2.LEFT
		is_moving = true
	elif Input.is_action_pressed("move_right"):
		direction = Vector2(1,0)
		velocity = speed*Vector2.RIGHT
		is_moving = true
	elif Input.is_action_pressed("move_up"):
		direction = Vector2(0,1)
		velocity = speed*Vector2.UP
		is_moving = true
	else:
		is_moving = false
	move_and_slide()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("out"):
		self.add_child(particles)
		particles.one_shot = true
		particles.emitting = true
		
