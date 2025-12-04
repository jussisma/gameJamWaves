extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const PROJECTILE_SCENE = preload("res://bullet.tscn")

var can_split: bool = true 
var speed: float = 400.0

func _process(delta: float) -> void:
	sprite.play("idle")

func _physics_process(delta: float) -> void:
	var direction = Vector2.UP.rotated(rotation)
	position += direction * speed * delta

func trigger_split_effect() -> void:
	if not can_split:
		return
		
	call_deferred("_spawn_8_bullets")

func _spawn_8_bullets() -> void:
	for i in range(8):
		var fragment = PROJECTILE_SCENE.instantiate()
		fragment.global_position = global_position
		
		var angle = (TAU / 8.0) * i
		fragment.rotation = angle
		
		fragment.can_split = false 
		
		fragment.modulate = Color(1, 0.5, 0.5)
		fragment.scale = Vector2(0.7, 0.7)
		
		get_tree().root.add_child(fragment)
	
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(50)
		queue_free()
