extends Node2D
# Procedurally scatters static obstacles (chairs/tables) across the arena at startup.
# They're StaticBody2D, so they automatically block player movement, enemy movement,
# AND the gun's raycast (cover) — no per-obstacle code needed.

@export var obstacle_count: int = 10
@export var area_size: Vector2 = Vector2(1100, 750)   # spread area, centered on this node
@export var min_gap: float = 150.0                    # min distance between obstacles -> walkable gaps
@export var clear_radius: float = 220.0               # keep this circle around the center clear (spawn-safe)

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
	var is_table := randf() < 0.45
	var box_size: Vector2 = Vector2(95, 95) if is_table else Vector2(48, 48)
	var color: Color = Color(0.45, 0.30, 0.18) if is_table else Color(0.38, 0.38, 0.44)

	var body := StaticBody2D.new()
	body.position = local_pos

	# collision (this is what blocks movement + the raycast)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = box_size
	col.shape = shape
	body.add_child(col)

	# placeholder visual (swap for chair/table art later)
	var hx: float = box_size.x * 0.5
	var hy: float = box_size.y * 0.5
	var vis := Polygon2D.new()
	vis.polygon = PackedVector2Array([
		Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)
	])
	vis.color = color
	body.add_child(vis)

	add_child(body)
