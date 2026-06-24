extends CanvasLayer
# Standalone HUD: player health bar + stacking inventory + score/wave + game-over screen.
# Kept separate from the team's ui.tscn on purpose, to avoid merge conflicts.

var player: Node2D
var health_bar: ProgressBar
var display_health: float = 0.0

var inventory_box: HBoxContainer
var inventory: Dictionary = {}   # item_id -> { "count": int, "label": Label }

var score_label: Label
var wave_label: Label
var _game_over: bool = false

func _ready() -> void:
	add_to_group("HUD")
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep running while the tree is paused (game over)

	#// Player health bar (top-left) \\#
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(260, 26)
	health_bar.position = Vector2(20, 20)
	health_bar.show_percentage = false
	add_child(health_bar)

	#// Score + wave (under the bar) \\#
	score_label = Label.new()
	score_label.position = Vector2(20, 54)
	add_child(score_label)
	wave_label = Label.new()
	wave_label.position = Vector2(20, 80)
	add_child(wave_label)

	#// Inventory row \\#
	inventory_box = HBoxContainer.new()
	inventory_box.position = Vector2(320, 18)
	inventory_box.add_theme_constant_override("separation", 16)
	add_child(inventory_box)

	#// Minimap (top-right): 180x120 with a 20px margin \\#
	var minimap = load("res://Script/minimap.gd").new()
	minimap.anchor_left = 1.0
	minimap.anchor_right = 1.0
	minimap.offset_left = -200.0    # 180 wide, 20px margin from right
	minimap.offset_top = 20.0
	minimap.offset_right = -20.0
	minimap.offset_bottom = 160.0   # 140 tall
	add_child(minimap)

func _process(delta: float) -> void:
	#// Health bar follows the player smoothly \\#
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
		if player == null:
			return
		display_health = player.Health
	health_bar.max_value = player.MaxHealth
	display_health = lerp(display_health, player.Health, 12.0 * delta)
	health_bar.value = display_health

	#// Score + wave \\#
	score_label.text = "Score: %d" % GameManager.score
	wave_label.text = "Wave: %d" % GameManager.wave

#// Call from pickup code: hud.add_item("Coin", coin_texture) \\#
func add_item(item_id: String, icon: Texture2D = null) -> void:
	if inventory.has(item_id):
		inventory[item_id].count += 1
		inventory[item_id].label.text = "x%d" % inventory[item_id].count
		return
	var slot := VBoxContainer.new()
	slot.alignment = BoxContainer.ALIGNMENT_CENTER
	if icon != null:
		var tex := TextureRect.new()
		tex.texture = icon
		tex.custom_minimum_size = Vector2(48, 48)
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		slot.add_child(tex)
	else:
		var name_lbl := Label.new()
		name_lbl.text = item_id
		slot.add_child(name_lbl)
	var count_label := Label.new()
	count_label.text = "x1"
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	slot.add_child(count_label)
	inventory_box.add_child(slot)
	inventory[item_id] = { "count": 1, "label": count_label }

#// Shown when the player dies. Pauses the game and offers a restart. \\#
func show_game_over() -> void:
	if _game_over:
		return
	_game_over = true
	get_tree().paused = true

	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.65)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 18)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(title)

	var result := Label.new()
	result.text = "Score: %d     Wave: %d" % [GameManager.score, GameManager.wave]
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.add_theme_font_size_override("font_size", 24)
	vbox.add_child(result)

	var btn := Button.new()
	btn.text = "Restart"
	btn.custom_minimum_size = Vector2(160, 44)
	btn.pressed.connect(_on_restart_pressed)
	vbox.add_child(btn)

func _on_restart_pressed() -> void:
	GameManager.score = 0
	GameManager.wave = 0
	get_tree().paused = false
	get_tree().reload_current_scene()

#// TEMP: press 1 / 2 / 3 to gather Coin / Gem / Ammo (stacks to x2, x3...). Remove later. \\#
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			add_item("Coin")
		elif event.keycode == KEY_2:
			add_item("Gem")
		elif event.keycode == KEY_3:
			add_item("Ammo")
