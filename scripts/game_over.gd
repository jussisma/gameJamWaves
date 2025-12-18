extends Control

@export var isWinning = true
@onready var title: Label = $Bg/BoxContainer/Title

func _ready() -> void:
	if (isWinning):
		title.text = "YOU WIN"
	else:
		title.text = "YOU LOSE"

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Maps.tscn")
