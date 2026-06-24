extends Node2D
# Procedurally scatters static obstacles (chairs/tables) across the arena at startup.
# They're StaticBody2D, so they automatically block player movement, enemy movement,
# AND the gun's raycast (cover) — no per-obstacle code needed.

@export var obstacle_count: int = 10
@export var area_size: Vector2 = Vector2(2200, 1500)  # spread area, centered on this node (bigger = sparser)
@export var min_gap: float = 360.0                    # min distance between obstacles -> wide walkable gaps
@export var clear_radius: float = 320.0               # keep this circle around the center clear (spawn-safe)

#// Obstacle art (swap in the Inspector if needed) \\#
@export var slot_texture: Texture2D = preload("res://Assets/SlotMachine.png")
@export var table_texture: Texture2D = preload("res://Assets/pokerTable.png")
@export var art_scale: float = 4.0                    # pixel art is tiny — scale it up

var _placed: Array[Vector2] = []

func _ready() -> void:
	# try many random spots; only keep ones that respect the clear zone and the min gap
	for attempt in obstacle_count * 30:
		if _placed.size() >= obstacle_count:
			break
		var pos := Vector2(
			randf_range(-area_size.x * 0.5, area_size.x * 0.5),
			randf_range(-area_size.y * 0.5, area_size.y * 0.5)
		)
		if pos.length() < clear_radius:
			continue                      # keep the middle clear so the player can move/spawn
		var too_close := false
		for p in _placed:
			if pos.distance_to(p) < min_gap:
				too_close = true
				break
		if too_close:
			continue                      # guarantees a walkable gap between obstacles
		_placed.append(pos)
		_make_obstacle(pos)

func _make_obstacle(local_pos: Vector2) -> void:
	# randomly a slot machine or a poker table
	var tex: Texture2D = slot_texture if randf() < 0.5 else table_texture

	var body := StaticBody2D.new()
	body.position = local_pos

	# the sprite (centered by default)
	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST   # crisp pixel art, no blur
	sprite.scale = Vector2(art_scale, art_scale)
	body.add_child(sprite)

	# collision sized to match the scaled art (centered, like the sprite)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(tex.get_size()) * art_scale
	col.shape = shape
	body.add_child(col)

	add_child(body)
