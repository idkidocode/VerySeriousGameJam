extends Node2D
# Spawns enemies in a ring around this node, every spawn_interval seconds.
# Same idea as your Flappy pipe spawner: a template (PackedScene) + a timer + instantiate.

@export var enemy_scene: PackedScene       # drag enemy.tscn into this slot in the Inspector
@export var spawn_interval: float = 2.0    # seconds between spawns (tune in Inspector)
@export var spawn_radius: float = 600.0    # how far from this node enemies appear

var _timer: float = 0.0

func _process(delta: float) -> void:
	# accumulate time, fire a spawn when we cross the interval, then reset
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn_enemy()

func _spawn_enemy() -> void:
	if enemy_scene == null:
		push_warning("Spawner has no enemy_scene assigned in the Inspector")
		return
	var enemy := enemy_scene.instantiate()   # make a copy of the template
	get_parent().add_child(enemy)            # add it to the scene (must be in tree before setting global_position)
	var angle := randf() * TAU               # random direction (TAU = full circle in radians)
	enemy.global_position = global_position + Vector2(cos(angle), sin(angle)) * spawn_radius
