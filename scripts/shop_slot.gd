extends TextureButton

# --- NOWOŚĆ: Eksportujemy zmienną, żeby ustawić ją w Inspektorze ---
@export var item_data: ShopItemData 

# Sygnały bez zmian
signal hovered(item: ShopItemData)
signal unhovered
signal bought(slot_node: Node, item: ShopItemData)

func _ready() -> void:
	# Jeśli w inspektorze przypisałeś przedmiot, załaduj go automatycznie
	if item_data != null:
		load_data()
	
	# Podłączanie sygnałów myszy
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

# Funkcja ładująca wygląd (zmieniona nazwa z 'setup' na 'load_data' dla porządku)
func load_data():
	$Icon.texture = item_data.icon
	$PriceLabel.text = str(item_data.price)

# --- Reszta funkcji bez większych zmian ---

func _on_mouse_entered():
	if item_data: # Sprawdzamy czy slot nie jest pusty
		z_index = 100
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
		hovered.emit(item_data)
		

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	unhovered.emit()
	z_index = 0

func _on_pressed():
	if item_data:
		bought.emit(self, item_data)
		
func update_slot_visuals(current_price: int, player_money: int) -> void:
	# Aktualizujemy tekst ceny
	%PriceLabel.text = str(current_price)
	
	# Zmieniamy kolor, jeśli gracza nie stać
	if player_money < current_price:
		%PriceLabel.modulate = Color.RED
		# Opcjonalnie: przyciemnij cały slot
		modulate = Color(0.7, 0.7, 0.7, 1) 
	else:
		%PriceLabel.modulate = Color.WHITE
		modulate = Color.WHITE		
