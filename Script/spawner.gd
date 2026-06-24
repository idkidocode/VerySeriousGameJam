extends Node2D
# Wave-based enemy spawner. Each wave spawns a batch of enemies in a ring around this node.
# When every enemy is dead, a short break, then the next (bigger) wave begins.

@export var enemy_scene: PackedScene        # drag enemy.tscn into this slot in the Inspector
@export var spawn_radius: float = 400.0     # how far from this node enemies appear
@export var base_enemies: int = 4           # enemies in wave 1
@export var enemies_added_per_wave: int = 2 # how many more each wave adds
@export var spawn_interval: float = 0.5     # seconds between each spawn within a wave
@export var time_between_waves: float = 3.0 # break after clearing a wave

var _to_spawn: int = 0          # enemies still to spawn this wave
var _spawn_timer: float = 0.0
var _between_waves: bool = true
var _wave_delay: float = 1.5    # short delay before the very first wave

func _ready() -> void:
	GameManager.wave = 0

func _process(delta: float) -> void:
	if enemy_scene == null:
		return

	if _between_waves:
		# counting down to the next wave
		_wave_delay -= delta
		if _wave_delay <= 0.0:
			_begin_wave()
		return

	if _to_spawn > 0:
		# still spawning this wave's batch
		_spawn_timer += delta
		if _spawn_timer >= spawn_interval:
			_spawn_timer = 0.0
			_spawn_enemy()
			_to_spawn -= 1
	else:
		# whole batch spawned — wait until they're all dead, then break before next wave
		if get_tree().get_nodes_in_group("Enemy").is_empty():
			_between_waves = true
			_wave_delay = time_between_waves

func _begin_wave() -> void:
	_between_waves = false
	GameManager.wave += 1
	_to_spawn = base_enemies + (GameManager.wave - 1) * enemies_added_per_wave
	_spawn_timer = spawn_interval   # spawn the first one immediately

func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	get_parent().add_child(enemy)
	# spawn in a ring around the PLAYER (so they come from all sides as you roam),
	# falling back to this node's position if the player isn't found
	var center := global_position
	var player := get_tree().get_first_node_in_group("Player")
	if player and is_instance_valid(player):
		center = player.global_position
	var angle := randf() * TAU
	enemy.global_position = center + Vector2(cos(angle), sin(angle)) * spawn_radius
