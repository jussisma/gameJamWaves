extends Control

# --- REFERENCJE ---
# Używamy %, o ile ustawiłeś "Access as Unique Name" w scenie
@onready var slots_container: Control = $SlotsContainer
@onready var name_label: Label = $InfoPanel/MarginContainer/VBoxContainer/NameLabel
@onready var desc_label: Label = $InfoPanel/MarginContainer/VBoxContainer/DescLabel
@onready var price_label: Label = $InfoPanel/MarginContainer/VBoxContainer/PriceLabel
@onready var merchant: AnimatedSprite2D = $Merchant # lub %Merchant
@onready var money_label: Label = $WalletPanel/MoneyLabel


func _ready() -> void:
	if merchant.sprite_frames.has_animation("idle"):
		merchant.play("idle")
	
	clear_info()
	
	# Zamiast populate_shop(), teraz po prostu podłączamy sygnały
	connect_slots()

func update_money_ui() -> void:
	# Pobieramy kasę z GameManager i wstawiamy do Labela
	money_label.text = str(GameGlobals.money) + " $" # lub "$"	

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
	var final_price = calculate_dynamic_price(item)
	
	# ... ustawianie tekstów ...
	price_label.text = str(final_price)
	
	# Logika kolorów
	if GameGlobals.money < final_price:
		price_label.modulate = Color.RED # Nie stać cię
	elif final_price < item.price:
		price_label.modulate = Color.GREEN # Promocja (Litość!)
		desc_label.text += "\n[PROMOCJA DLA POTRZEBUJĄCYCH!]"
	elif final_price > item.price:
		price_label.modulate = Color.ORANGE # Drożyzna (Popyt!)
		desc_label.text += "\n[CENA WZROSŁA PRZEZ POPYT]"
	else:
		price_label.modulate = Color.WHITE

func clear_info() -> void:
	name_label.text = ""
	desc_label.text = "Choose an item..."
	price_label.text = ""

func apply_effect(item_id: String):
	match item_id:
		"medkit":
			# Leczymy do pełna
			GameGlobals.health = GameGlobals.max_health
			
		"ammo":
			# Używamy Twojej gotowej funkcji z GameGlobals!
			# Dodajemy 30 naboi (lub tyle ile uważasz)
			GameGlobals.add_ammunition(30)
			
		"speed":
			# POPRAWKA: Mnożymy przez 1.15, żeby zwiększyć o 15%
			GameGlobals.speed = GameGlobals.speed * 1.15
			
		"armor":
			GameGlobals.max_health = GameGlobals.max_health + 50
			# Opcjonalnie: Ulecz o te 50 pkt od razu, żeby nie mieć pustego paska
			GameGlobals.health += 50 
		
		"magnet":
			if not GameGlobals.magnet_unlocked:
				GameGlobals.magnet_unlocked = true
				GameGlobals.magnet_range = 150.0
			else:
				# Jeśli kupujemy drugi raz, zwiększamy zasięg
				GameGlobals.magnet_range += 100.0
			
		"wormhole":
			GameGlobals.extra_life = true
		
		"rifle":
			# POPRAWKA: Zwiększamy obrażenia o 20% (mnożnik 1.2)
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
		
		# NOWOŚĆ: Po wydaniu kasy, odświeżamy ceny pozostałych przedmiotów!
		# (Bo może teraz stać nas na mniej rzeczy, albo Safety Net zmienił ceny)
		update_all_slots_visuals()
		
		print("Kupiono: " + item.name + " za: " + str(final_price))
	else:
		print("Nie stać cię!")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_shop"):
		if visible:
			close_shop()
		else:
			open_shop()

func open_shop():
	update_money_ui()
	
	# NOWOŚĆ: Aktualizujemy ceny na kafelkach
	update_all_slots_visuals()
	
	visible = true
	get_tree().paused = true 
	clear_info()

func close_shop():
	visible = false
	get_tree().paused = false # WZNAWIA GRE
	
	# Opcjonalnie: Ukryj kursor myszy (wróć do sterowania grą)
	# Input.mouse_mode = Input.MOUSE_MODE_CAPTURED		
	
func calculate_dynamic_price(item: ShopItemData) -> int:
	var base_price = item.price
	var multiplier: float = 1.0
	
	var hp_percent = GameGlobals.health / GameGlobals.max_health
	var money = GameGlobals.money
	
	# --- 1. ANALIZA POTRZEB (Zmieniamy tylko mnożnik) ---
	match item.id:
		"medkit":
			if hp_percent < 0.25: multiplier *= 2.0  # Bardzo drogo jak umierasz
			elif hp_percent < 0.5: multiplier *= 1.5
			elif hp_percent > 0.9: multiplier *= 0.8 # Promocja dla zdrowych

		"ammo":
			var current_ammo = GameGlobals.get_current_weapon_ammo()
			if current_ammo == 0: multiplier *= 2.0
			elif current_ammo < 10: multiplier *= 1.5
			
		"magnet":
			if GameGlobals.magnet_unlocked: multiplier *= 1.5

	# --- 2. INFLACJA (Dla bogaczy) ---
	if money > 500: # Obniżyłem próg, żebyś szybciej zauważył efekt
		multiplier *= 1.2
		
	# --- 3. SYSTEM LITOŚCI (Naprawiony) ---
	# Jeśli gracz jest biedny, dajemy zniżkę, ale NIE KASUJEMY wcześniejszego mnożnika.
	# Używamy *= zamiast =
	var is_essential = item.id in ["medkit", "ammo"]
	
	if money < 100 and is_essential:
		multiplier *= 0.6 # Zniżka 40% dla biednych
	
	# --- OBLICZENIE CENY WSTĘPNEJ ---
	var calculated_price = int(base_price * multiplier)
	
	# --- 4. OSTATECZNY RATUNEK (Safety Net) ---
	# To sprawiało, że cena stała w miejscu.
	# Zmieniamy logikę: Jeśli gracza nie stać na APTECZKĘ/AMUNICJĘ,
	# to cena spada do jego stanu konta, ALE nie może być niższa niż 10.
	
	if is_essential and money < calculated_price and money >= 10:
		return money # Gracz wydaje wszystko co ma (widzisz cenę równą posiadanej kasie)
	
	# Zawsze minimum 10 (żeby nie było za darmo)
	return max(10, calculated_price)	
	
func update_all_slots_visuals() -> void:
	var slots = slots_container.get_children()
	
	for slot in slots:
		# Sprawdzamy czy to właściwy slot i czy ma dane
		if "item_data" in slot and slot.item_data != null:
			
			# 1. Obliczamy cenę algorytmem AI
			var current_price = calculate_dynamic_price(slot.item_data)
			
			# 2. Wywołujemy funkcję wewnątrz slotu (bezpieczniejszy sposób)
			if slot.has_method("update_slot_visuals"):
				slot.update_slot_visuals(current_price, GameGlobals.money)	
