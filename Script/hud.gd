extends CanvasLayer
# Standalone HUD: player health bar (same style as enemies) + a stacking item inventory.
# Kept separate from the team's ui.tscn on purpose, to avoid merge conflicts.

var player: Node2D
var health_bar: ProgressBar
var display_health: float = 0.0

var inventory_box: HBoxContainer
var inventory: Dictionary = {}   # item_id -> { "count": int, "label": Label }

func _ready() -> void:
	#// Player health bar (top-left) \\#
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(260, 26)
	health_bar.position = Vector2(20, 20)
	health_bar.show_percentage = false
	add_child(health_bar)

	#// Inventory row (top, next to the bar) \\#
	inventory_box = HBoxContainer.new()
	inventory_box.position = Vector2(320, 18)
	inventory_box.add_theme_constant_override("separation", 16)
	add_child(inventory_box)

func _process(delta: float) -> void:
	#// Follow the player's health, smoothly (like the enemy bars) \\#
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
		if player == null:
			return
		display_health = player.Health   # init so the bar doesn't animate up from 0
	health_bar.max_value = player.MaxHealth
	display_health = lerp(display_health, player.Health, 12.0 * delta)
	health_bar.value = display_health

#// Call from pickup code: get the HUD and do hud.add_item("Coin", coin_texture) \\#
func add_item(item_id: String, icon: Texture2D = null) -> void:
	if inventory.has(item_id):
		# already have it -> bump the count and show xN
		inventory[item_id].count += 1
		inventory[item_id].label.text = "x%d" % inventory[item_id].count
		return
	# first time seeing this item -> make a new slot
	var slot := VBoxContainer.new()
	slot.alignment = BoxContainer.ALIGNMENT_CENTER
	if icon != null:
		var tex := TextureRect.new()
		tex.texture = icon
		tex.custom_minimum_size = Vector2(48, 48)
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.add_child(tex)
	else:
		var name_lbl := Label.new()        # placeholder name until items have icons
		name_lbl.text = item_id
		slot.add_child(name_lbl)
	var count_label := Label.new()
	count_label.text = "x1"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_child(count_label)
	inventory_box.add_child(slot)
	inventory[item_id] = { "count": 1, "label": count_label }

#// TEMP: lets you SEE the inventory work before real pickups exist.
#// Press 1 / 2 / 3 to gather Coin / Gem / Ammo (press again to stack -> x2, x3...). Remove later.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			add_item("Coin")
		elif event.keycode == KEY_2:
			add_item("Gem")
		elif event.keycode == KEY_3:
			add_item("Ammo")
