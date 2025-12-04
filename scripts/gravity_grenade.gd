extends Area2D

const BLACK_HOLE_SCENE = preload("res://scenes/BlackHole.tscn") 
@onready var sprite_2d: Sprite2D = $CollisionShape2D/Sprite2D

@export var speed: float = 600.0
var direction: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var traveled_distance: float = 0.0
var max_distance: float = 0.0

func setup(start_pos: Vector2, target: Vector2):
	global_position = start_pos
	target_pos = target
	direction = (target - start_pos).normalized()
	max_distance = start_pos.distance_to(target)
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	var move_step = speed * delta
	position += direction * move_step
	traveled_distance += move_step
	
	sprite_2d.rotation_degrees += 720 * delta
	
	if traveled_distance >= max_distance:
		explode()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player": return 
	explode()

func explode():
	var hole = BLACK_HOLE_SCENE.instantiate()
	hole.global_position = global_position
	get_tree().root.add_child(hole)
	
	queue_free()
