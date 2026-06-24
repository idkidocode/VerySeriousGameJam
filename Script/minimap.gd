extends Control
# Player-centered minimap for an open/infinite map: the player sits in the middle,
# enemies appear as red dots around them within `view_range` world units.

@export var view_range: Vector2 = Vector2(2400, 2400)  # world span shown across the whole map

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# background + border
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.4), false, 2.0)

	var player := get_tree().get_first_node_in_group("Player")
	var center := Vector2.ZERO
	if player and is_instance_valid(player):
		center = player.global_position
		draw_circle(size * 0.5, 4.0, Color.WHITE)   # player is always dead center

	for e in get_tree().get_nodes_in_group("Enemy"):
		if is_instance_valid(e):
			draw_circle(_to_map(e.global_position, center), 3.0, Color(1.0, 0.2, 0.2))

func _to_map(world_pos: Vector2, center: Vector2) -> Vector2:
	var rel := (world_pos - center) / view_range + Vector2(0.5, 0.5)
	rel.x = clampf(rel.x, 0.0, 1.0)
	rel.y = clampf(rel.y, 0.0, 1.0)
	return rel * size
