extends Node2D

@onready var ui: Control = $InGameUI

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui.init_ui(1, 1, 1, 500, 20, "big gun")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
