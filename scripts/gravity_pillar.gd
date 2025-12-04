extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("trigger_split_effect"):
		area.trigger_split_effect()
		play_activation_effect()

func play_activation_effect() -> void:
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)
