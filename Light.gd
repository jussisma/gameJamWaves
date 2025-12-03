extends PointLight2D

@export var low_energy: float = 0.0      # off
@export var high_energy: float = 0.7    # on
@export var min_delay: float = 0.1       # delay min between two cut
@export var max_delay: float = 0.5      # delai max between two cut
@export var fade_time: float = 0.1       # duration fade in / fade out

var is_on: bool = true
var tween: Tween
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	energy = high_energy
	_start_cycle()

func _start_cycle() -> void:
	# Chose a random delay before the next state
	var delay = rng.randf_range(min_delay, max_delay)
	await get_tree().create_timer(delay).timeout
	_toggle_light()

func _toggle_light() -> void:
	if tween:
		tween.kill()

	tween = create_tween()

	var target := low_energy
	if not is_on:
		target = high_energy

	tween.tween_property(self, "energy", target, fade_time)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(_on_fade_finished)

func _on_fade_finished() -> void:
	is_on = not is_on
	_start_cycle()
