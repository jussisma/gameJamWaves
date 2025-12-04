extends PointLight2D

@export var low_energy: float = 0.4
@export var high_energy: float = 1.2
@export var duration: float = 0.5  # Duration from low to high

var going_up: bool = true
var tween: Tween

func _ready() -> void:
	energy = low_energy
	_start_tween()

func _start_tween() -> void:
	if tween:
		tween.kill()

	tween = create_tween()

	var target_energy := high_energy
	if not going_up:
		target_energy = low_energy

	tween.tween_property(self, "energy", target_energy, duration)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	going_up = not going_up
	_start_tween()
