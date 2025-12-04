extends Area2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _process(delta: float) -> void:
	sprite.play("idle")

var speed: float = 400.0

func _physics_process(delta: float) -> void:
	# Como tu sprite apunta hacia ARRIBA, nos movemos en la dirección
	# de su vector UP rotado.
	# (Si usaras Vector2.RIGHT aquí, la bala se movería de lado como un cangrejo)
	var direction = Vector2.UP.rotated(rotation)
	
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("enemy")):
		body.take_damage(50)
		queue_free()
	if(body.is_in_group("wall")):
		queue_free()
