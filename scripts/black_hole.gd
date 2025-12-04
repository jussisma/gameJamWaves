extends Area2D

@export var lifetime: float = 4.0
@export var pull_strength: float = 800.0 
@export var no_escape_radius: float = 120.0 

@export var suck_speed: float = 200.0
@export var rotation_speed: float = 400.0

func _ready() -> void:
	scale = Vector2(1.0, 1.0)
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	
	await get_tree().create_timer(lifetime).timeout
	
	var end_tween = create_tween()
	end_tween.tween_property(self, "scale", Vector2(0, 0), 0.3)
	await end_tween.finished
	queue_free()

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is CharacterBody2D and body != get_parent():
			var vec_to_center = global_position - body.global_position
			var distance = vec_to_center.length()
			var direction_in = vec_to_center.normalized()
			
			var direction_tangent = direction_in.rotated(PI / 2)

			if distance < no_escape_radius:
				var spiral_velocity = (direction_in * suck_speed) + (direction_tangent * rotation_speed)
				body.velocity = spiral_velocity * 2.0
				body.rotation_degrees += 720 * delta
				body.move_and_slide()
				
			else:

				var base_pull = 200.0
				
				var calculated_force = (pull_strength / distance) + base_pull
				
				body.velocity += direction_in * calculated_force * delta

				body.velocity += direction_tangent * (calculated_force * 0.3) * delta
