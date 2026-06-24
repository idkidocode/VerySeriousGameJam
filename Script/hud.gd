extends CanvasLayer
# HUD: health bar, chip currency counters, score/wave, minimap, wave banner, game over.
# Kept separate from the team's ui.tscn on purpose, to avoid merge conflicts.

var player: Node2D
var health_bar: ProgressBar
var display_health: float = 0.0

var red_label: Label
var yellow_label: Label
var blue_label: Label

var score_label: Label
var wave_label: Label
var wave_banner: Label
var _last_wave: int = 0
var _banner_timer: float = 0.0
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

	#// Currency list, vertical, below the health bar \\#
	var chips_box := VBoxContainer.new()
	chips_box.position = Vector2(20, 56)
	chips_box.add_theme_constant_override("separation", 4)
	add_child(chips_box)
	red_label = _make_chip_row(chips_box, preload("res://Assets/Redchips.png"))
	yellow_label = _make_chip_row(chips_box, preload("res://Assets/Yellowchips.png"))
	blue_label = _make_chip_row(chips_box, preload("res://Assets/Bluechips.png"))

	#// Score + wave, below the chips \\#
	score_label = Label.new()
	score_label.position = Vector2(20, 156)
	add_child(score_label)
	wave_label = Label.new()
	wave_label.position = Vector2(20, 182)
	add_child(wave_label)

	#// Big centered "WAVE N" / "WAVE CLEARED" banner \\#
	wave_banner = Label.new()
	wave_banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wave_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wave_banner.add_theme_font_size_override("font_size", 64)
	wave_banner.visible = false
	add_child(wave_banner)

	#// Minimap (top-right) \\#
	var minimap = load("res://Script/minimap.gd").new()
	minimap.anchor_left = 1.0
	minimap.anchor_right = 1.0
	minimap.offset_left = -200.0
	minimap.offset_top = 20.0
	minimap.offset_right = -20.0
	minimap.offset_bottom = 160.0
	add_child(minimap)

func _make_chip_row(parent: VBoxContainer, icon: Texture2D) -> Label:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var tex := TextureRect.new()
	tex.texture = icon
	tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex.custom_minimum_size = Vector2(28, 28)
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(tex)
	var lbl := Label.new()
	lbl.text = "0"
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)
	parent.add_child(row)
	return lbl

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

	#// Currency counters \\#
	red_label.text = "%d" % GameManager.red_chips
	yellow_label.text = "%d" % GameManager.yellow_chips
	blue_label.text = "%d" % GameManager.blue_chips

	#// Score + wave \\#
	score_label.text = "Score: %d" % GameManager.score
	wave_label.text = "Wave: %d" % GameManager.wave

	#// Flash the banner whenever the wave number changes \\#
	if GameManager.wave != _last_wave:
		_last_wave = GameManager.wave
		if GameManager.wave > 0:
			flash_banner("WAVE %d" % GameManager.wave)
	if _banner_timer > 0.0:
		_banner_timer -= delta
		if _banner_timer <= 0.0:
			wave_banner.visible = false

#// Show a big centered message for `duration` seconds (e.g. "WAVE 2", "WAVE CLEARED") \\#
func flash_banner(text: String, duration: float = 2.0) -> void:
	wave_banner.text = text
	wave_banner.visible = true
	_banner_timer = duration

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
	GameManager.red_chips = 0
	GameManager.yellow_chips = 0
	GameManager.blue_chips = 0
	get_tree().paused = false
	get_tree().reload_current_scene()

#// TEMP: press 1 / 2 / 3 to gain a red / yellow / blue chip (test the counters + multipliers). Remove later. \\#
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			GameManager.red_chips += 1
		elif event.keycode == KEY_2:
			GameManager.yellow_chips += 1
		elif event.keycode == KEY_3:
			GameManager.blue_chips += 1
