extends Node2D

@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@export var level_music: AudioStream
func _ready() -> void:
	GameGlobals.initialize_game({
	"level": 1,
	"health": 100.0,
	"weapons": ["Glock P80", "Revolver Colt 45", "Submachine MP5A3", "AK47", "Bazooka M20"],
	"player": character_body_2d
})
	if level_music:
		AudioManager.play_music(level_music)
