extends Node2D
# Wave-based enemy spawner. Each wave: flash "WAVE N", give the player a breather,
# then spawn the batch in a ring around the player. When the wave is wiped out,
# flash "WAVE CLEARED", take a break, then start the next (bigger) wave.

@export var enemy_scene: PackedScene
@export var spawn_radius: float = 400.0
@export var base_enemies: int = 4
@export var enemies_added_per_wave: int = 2
@export var spawn_interval: float = 0.5      # seconds between spawns within a wave
@export var wave_start_delay: float = 2.5    # breathing time after a wave starts, before enemies appear
@export var time_between_waves: float = 3.0  # break after clearing a wave

var _to_spawn: int = 0
var _spawn_timer: float = 0.0
var _between_waves: bool = true
var _wave_delay: float = 1.5
var _prepping: bool = false
var _prep_timer: float = 0.0

func _ready() -> void:
	GameManager.wave = 0

func _process(delta: float) -> void:
	if enemy_scene == null:
		return

	# break between waves
	if _between_waves:
		_wave_delay -= delta
		if _wave_delay <= 0.0:
			_begin_wave()
		return

	# breathing time at the start of a wave (banner showing, no enemies yet)
	if _prepping:
		_prep_timer -= delta
		if _prep_timer <= 0.0:
			_prepping = false
			_spawn_timer = spawn_interval   # first enemy spawns right after the breather
		return

	# spawn the batch
	if _to_spawn > 0:
		_spawn_timer += delta
		if _spawn_timer >= spawn_interval:
			_spawn_timer = 0.0
			_spawn_enemy()
			_to_spawn -= 1
	else:
		# whole batch spawned — wait until they're all dead
		if get_tree().get_nodes_in_group("Enemy").is_empty():
			_wave_cleared()

func _begin_wave() -> void:
	_between_waves = false
	GameManager.wave += 1            # HUD flashes "WAVE N" on this change
	_to_spawn = base_enemies + (GameManager.wave - 1) * enemies_added_per_wave
	_prepping = true
	_prep_timer = wave_start_delay   # give the player a moment before enemies arrive

func _wave_cleared() -> void:
	var hud := get_tree().get_first_node_in_group("HUD")
	if hud and hud.has_method("flash_banner"):
		hud.flash_banner("WAVE CLEARED")
	_between_waves = true
	_wave_delay = time_between_waves

func _spawn_enemy() -> void:
	var enemy := enemy_scene.instantiate()
	get_parent().add_child(enemy)
	# spawn in a ring around the PLAYER (so they come from all sides as you roam)
	var center := global_position
	var player := get_tree().get_first_node_in_group("Player")
	if player and is_instance_valid(player):
		center = player.global_position
	var angle := randf() * TAU
	enemy.global_position = center + Vector2(cos(angle), sin(angle)) * spawn_radius
