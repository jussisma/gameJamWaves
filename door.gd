extends Node2D
class_name Door

signal door_opened(door)

@export var cost: int = 100
@export var door_layer: int = 0

# Définir les 16 tuiles de la porte (positions relatives)
# Exemple pour une porte 4x4
@export var door_tiles: Array[Vector2i] = [
	Vector2i(64,36), Vector2i(65,36), Vector2i(66,36), Vector2i(67,36),  # Rangée 1
	Vector2i(64,37), Vector2i(65,37), Vector2i(66,37), Vector2i(67,37),  # Rangée 2
	Vector2i(64,38), Vector2i(65,38), Vector2i(66,38), Vector2i(67,38),  # Rangée 3
	Vector2i(64,39), Vector2i(65,39), Vector2i(66,39), Vector2i(67,39)   # Rangée 4
]

# Position de départ de la porte dans le TileMap (coin supérieur gauche)
@export var door_start_position: Vector2i = Vector2i(10, 5)

# Atlas coords pour la porte fermée (16 tuiles)
@export var closed_door_atlas: Array[Vector2i] = [
	Vector2i(64,36), Vector2i(65,36), Vector2i(66,36), Vector2i(67,36),  # Rangée 1
	Vector2i(64,37), Vector2i(65,37), Vector2i(66,37), Vector2i(67,37),  # Rangée 2
	Vector2i(64,38), Vector2i(65,38), Vector2i(66,38), Vector2i(67,38),  # Rangée 3
	Vector2i(64,39), Vector2i(65,39), Vector2i(66,39), Vector2i(67,39)
]

# Atlas coords pour la porte ouverte (16 tuiles)
@export var open_door_atlas: Array[Vector2i] = [
	Vector2i(68,36), Vector2i(69,36), Vector2i(70,36), Vector2i(71,36),
	Vector2i(68,37), Vector2i(69,37), Vector2i(70,37), Vector2i(71,37),
	Vector2i(68,38), Vector2i(69,38), Vector2i(70,38), Vector2i(71,38),
	Vector2i(68,39), Vector2i(69,39), Vector2i(70,39), Vector2i(71,39)
]

var is_open = false
var player_in_range = false
var player_ref = null

func _ready():
	$Area2D.body_entered.connect(_on_area_body_entered)
	$Area2D.body_exited.connect(_on_area_body_exited)

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body

func _on_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null

func _input(event):
	if player_in_range and event.is_action_pressed("interact") and not is_open:
		attempt_open()

func attempt_open():
	if player_ref and player_ref.has_method("spend_money"):
		if player_ref.spend_money(cost):
			open_door()

func open_door():
	is_open = true
	
	# Désactiver les collisions
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	
	# Changer les 16 tuiles de la porte
	var source_id = $TileMap.get_cell_source_id(door_layer, door_start_position)
	
	for i in range(door_tiles.size()):
		var cell_pos = door_start_position + door_tiles[i]
		$TileMap.set_cell(door_layer, cell_pos, source_id, open_door_atlas[i])
	
	door_opened.emit(self)
