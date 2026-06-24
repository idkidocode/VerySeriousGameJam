extends Node2D
# Builds 4 static walls forming a rectangular room of `arena_size`, centered on this node.
# StaticBody2D walls automatically confine the player and enemies (and stop bullets).

@export var arena_size: Vector2 = Vector2(1300, 900)
@export var wall_thickness: float = 40.0

func _ready() -> void:
	var hx := arena_size.x * 0.5
	var hy := arena_size.y * 0.5
	var t := wall_thickness
	_make_wall(Vector2(0, -hy - t * 0.5), Vector2(arena_size.x + t * 2.0, t))  # top
	_make_wall(Vector2(0,  hy + t * 0.5), Vector2(arena_size.x + t * 2.0, t))  # bottom
	_make_wall(Vector2(-hx - t * 0.5, 0), Vector2(t, arena_size.y))            # left
	_make_wall(Vector2( hx + t * 0.5, 0), Vector2(t, arena_size.y))            # right

func _make_wall(local_pos: Vector2, box: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = local_pos

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = box
	col.shape = shape
	body.add_child(col)

	var hx := box.x * 0.5
	var hy := box.y * 0.5
	var vis := Polygon2D.new()
	vis.polygon = PackedVector2Array([Vector2(-hx, -hy), Vector2(hx, -hy), Vector2(hx, hy), Vector2(-hx, hy)])
	vis.color = Color(0.22, 0.20, 0.28)
	body.add_child(vis)

	add_child(body)
