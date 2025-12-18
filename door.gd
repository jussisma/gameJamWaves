extends Node2D
class_name Door

signal door_opened(door)

@export var cost: int = 100
@export var debug_mode: bool = true

var is_open = false
var player_in_range = false
var player_ref = null

func _ready():
	# Démarrer avec l'animation "closed"
	$AnimatedSprite2D.play("closed")
	
	$Area2D.body_entered.connect(_on_area_body_entered)
	$Area2D.body_exited.connect(_on_area_body_exited)
	
	if debug_mode:
		print("[DEBUG MODE ACTIVÉ] Porte ", name, " - ouverture automatique au contact")

func _on_area_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		print("Joueur détecté près de la porte")
		
		if debug_mode and not is_open:
			print("[DEBUG] Ouverture automatique sans paiement")
			open_door()

func _on_area_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		player_ref = null

func _input(event):
	if not debug_mode and player_in_range and event.is_action_pressed("interact") and not is_open:
		attempt_open()

func attempt_open():
	print("Tentative d'ouverture - Coût: ", cost)
	if player_ref and player_ref.has_method("spend_money"):
		if player_ref.spend_money(cost):
			open_door()
		else:
			print("Pas assez d'argent!")

func open_door():
	print("=== OUVERTURE DE LA PORTE ===")
	is_open = true
	
	# Désactiver les collisions
	$StaticBody2D/CollisionShape2D.set_deferred("disabled", true)
	print("✓ Collisions désactivées")
	
	# Jouer l'animation d'ouverture
	$AnimatedSprite2D.play("open")
	
	print("✓ Porte ouverte!")
	door_opened.emit(self)
