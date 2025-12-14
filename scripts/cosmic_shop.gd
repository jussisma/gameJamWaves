extends Control

# --- REFERENCJE ---
# Używamy %, o ile ustawiłeś "Access as Unique Name" w scenie
@onready var slots_container: Control = $SlotsContainer
@onready var name_label: Label = $InfoPanel/MarginContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $InfoPanel/MarginContainer/VBoxContainer/DescLabel
@onready var price_label: Label = $InfoPanel/MarginContainer/VBoxContainer/PriceLabel
@onready var merchant: AnimatedSprite2D = $Merchant # lub %Merchant

var player_money: int = 500 

func _ready() -> void:
	if merchant.sprite_frames.has_animation("idle"):
		merchant.play("idle")
	
	clear_info()
	
	# Zamiast populate_shop(), teraz po prostu podłączamy sygnały
	connect_slots()

func connect_slots() -> void:
	# Pobieramy wszystkie dzieci z kontenera (czyli nasze ręcznie ustawione sloty)
	var slots = slots_container.get_children()
	
	for slot in slots:
		# Sprawdzamy, czy to na pewno nasz ShopSlot i czy ma przypisany przedmiot
		if slot.has_signal("hovered") and slot.item_data != null:
			slot.hovered.connect(_on_slot_hovered)
			slot.unhovered.connect(clear_info)
			slot.bought.connect(_on_slot_bought)

# --- Reszta logiki UI i Kupowania pozostaje TAKA SAMA ---

func _on_slot_hovered(item: ShopItemData) -> void:
	name_label.text = item.name
	desc_label.text = item.description
	price_label.text = str(item.price) + " credits"
	
	if player_money < item.price:
		price_label.modulate = Color.RED
	else:
		price_label.modulate = Color.GREEN

func clear_info() -> void:
	name_label.text = ""
	desc_label.text = "Choose an item..."
	price_label.text = ""

func _on_slot_bought(slot_node: Node, item: ShopItemData) -> void:
	if player_money >= item.price:
		player_money -= item.price
		
		# ZNIKANIE:
		slot_node.queue_free() # Usuwa slot ze sceny
		# lub jeśli chcesz tylko ukryć: slot_node.visible = false
		
		clear_info()
	else:
		pass
