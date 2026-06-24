extends Control
# Minimap: draws a white dot for the player and red dots for enemies,
# scaled from world coordinates into this little box. Keep arena_center/size
# matching the ArenaBounds node so the map lines up with the real room.

@export var arena_center: Vector2 = Vector2(450, 350)
@export var arena_size: Vector2 = Vector2(1300, 900)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# background + border
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.4), false, 2.0)

	var player := get_tree().get_first_node_in_group("Player")
	if player and is_instance_valid(player):
		draw_circle(_to_map(player.global_position), 4.0, Color.WHITE)

	for e in get_tree().get_nodes_in_group("Enemy"):
		if is_instance_valid(e):
			draw_circle(_to_map(e.global_position), 3.0, Color(1.0, 0.2, 0.2))

func _to_map(world_pos: Vector2) -> Vector2:
	var rel := (world_pos - arena_center) / arena_size + Vector2(0.5, 0.5)
	rel.x = clampf(rel.x, 0.0, 1.0)
	rel.y = clampf(rel.y, 0.0, 1.0)
	return rel * size
