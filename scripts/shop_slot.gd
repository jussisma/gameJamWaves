extends TextureButton

@export var item_data: ShopItemData 

signal hovered(item: ShopItemData)
signal unhovered
signal bought(slot_node: Node, item: ShopItemData)

func _ready() -> void:
	if item_data != null:
		load_data()
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)

func load_data():
	$Icon.texture = item_data.icon
	$PriceLabel.text = str(item_data.price)


func _on_mouse_entered():
	if item_data:
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
	%PriceLabel.text = str(current_price)
	
	if player_money < current_price:
		%PriceLabel.modulate = Color.RED
		modulate = Color(0.7, 0.7, 0.7, 1) 
	else:
		%PriceLabel.modulate = Color.WHITE
		modulate = Color.WHITE		
