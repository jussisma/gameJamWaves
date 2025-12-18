extends Control

@onready var slots_container: Control = $SlotsContainer
@onready var name_label: Label = $InfoPanel/MarginContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $InfoPanel/MarginContainer/VBoxContainer/DescLabel
@onready var price_label: Label = $InfoPanel/MarginContainer/VBoxContainer/PriceLabel
@onready var merchant: AnimatedSprite2D = $Merchant 
@onready var money_label: Label = $WalletPanel/MoneyLabel


func _ready() -> void:
	if merchant.sprite_frames.has_animation("idle"):
		merchant.play("idle")
	
	clear_info()

	connect_slots()

func update_money_ui() -> void:
	money_label.text = str(GameGlobals.money) + " $"

func connect_slots() -> void:
	var slots = slots_container.get_children()
	
	for slot in slots:
		if slot.has_signal("hovered") and slot.item_data != null:
			slot.hovered.connect(_on_slot_hovered)
			slot.unhovered.connect(clear_info)
			slot.bought.connect(_on_slot_bought)


func _on_slot_hovered(item: ShopItemData) -> void:
	var final_price = calculate_dynamic_price(item)
	
	name_label.text = item.name
	desc_label.text = item.description 
	
	price_label.text = str(final_price)
	
	if GameGlobals.money < final_price:
		price_label.modulate = Color.RED 
	elif final_price < item.price:
		price_label.modulate = Color.GREEN 
	elif final_price > item.price:
		price_label.modulate = Color.ORANGE 
	else:
		price_label.modulate = Color.WHITE

func clear_info() -> void:
	name_label.text = ""
	desc_label.text = "Choose an item..."
	price_label.text = ""

func apply_effect(item_id: String):
	match item_id:
		"medkit":
			GameGlobals.health = GameGlobals.max_health
			
		"ammo":
			GameGlobals.add_ammunition(30)
			
		"speed":
			GameGlobals.speed = GameGlobals.speed * 1.15
			
		"armor":
			GameGlobals.max_health = GameGlobals.max_health + 50
			GameGlobals.health += 50 
		
		"magnet":
			if not GameGlobals.magnet_unlocked:
				GameGlobals.magnet_unlocked = true
				GameGlobals.magnet_range = 150.0
			else:
				GameGlobals.magnet_range += 100.0
			
		"wormhole":
			GameGlobals.extra_life = true
		
		"rifle":
			GameGlobals.damage = GameGlobals.damage * 1.2	
		
		"elixir":
			GameGlobals.power_points = GameGlobals.power_points + 20		
				

func _on_slot_bought(slot_node: Node, item: ShopItemData) -> void:
	var final_price = calculate_dynamic_price(item)
	
	if GameGlobals.money >= final_price:
		GameGlobals.money -= final_price
		apply_effect(item.id)
		slot_node.queue_free()
		clear_info()
		update_money_ui()
		
		update_all_slots_visuals()
		
		print("Bought: " + item.name + " za: " + str(final_price))
	else:
		print("no money")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_shop"):
		print(visible)
		if visible:
			close_shop()
		else:
			open_shop()

func open_shop():
	update_money_ui()
	
	update_all_slots_visuals()
	
	visible = true
	get_tree().paused = true 
	clear_info()

func close_shop():
	visible = false
	get_tree().paused = false 
		
	
func calculate_dynamic_price(item: ShopItemData) -> int:
	var base_price = item.price
	var multiplier: float = 1.0
	
	var hp_percent = GameGlobals.health / GameGlobals.max_health
	var money = GameGlobals.money
	
	match item.id:
		"medkit":
			if hp_percent < 0.25: multiplier *= 2.0  
			elif hp_percent < 0.5: multiplier *= 1.5
			elif hp_percent > 0.9: multiplier *= 0.8 

		"ammo":
			var current_ammo = GameGlobals.get_current_weapon_ammo()
			if current_ammo == 0: multiplier *= 2.0
			elif current_ammo < 10: multiplier *= 1.5
			
		"magnet":
			if GameGlobals.magnet_unlocked: multiplier *= 1.5

	if money > 500: 
		multiplier *= 1.2
		
	var is_essential = item.id in ["medkit", "ammo"]
	
	if money < 100 and is_essential:
		multiplier *= 0.6 
	
	var calculated_price = int(base_price * multiplier)

	
	if is_essential and money < calculated_price and money >= 10:
		return money 
	
	return max(10, calculated_price)	
	
func update_all_slots_visuals() -> void:
	var slots = slots_container.get_children()
	
	for slot in slots:
		if "item_data" in slot and slot.item_data != null:
			
			var current_price = calculate_dynamic_price(slot.item_data)
			
			if slot.has_method("update_slot_visuals"):
				slot.update_slot_visuals(current_price, GameGlobals.money)	
