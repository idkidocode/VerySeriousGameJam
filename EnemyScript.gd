extends CharacterBody2D

@export var Health: float = 100
var MaxHealth: float

@onready var health_bar: ProgressBar = $HealthBar
var display_health: float

@onready var sprite_2d: Sprite2D = $Sprite2D

var Hit_tween: Tween

#// Chase AI \\#
@export var MoveSpeed: float = 120.0
@export var ContactDamage: float = 10.0
var player: Node2D
var _dead: bool = false

func _ready() -> void:
	#// Start up things \\#
	MaxHealth = Health
	health_bar.max_value = MaxHealth
	health_bar.value = Health
	health_bar.visible = false


func _process(delta: float) -> void:
	#// Smooth HealthBar \\#
	display_health = lerp(display_health, Health, 12.0 * delta)
	health_bar.value = display_health

func HitEffect(effect_Speed: float) -> void:
	#// Hit color \\#
	var Target_color = Color(0.48, 0.48, 0.48, 1.0)
	
	if Hit_tween and Hit_tween.is_valid():
		Hit_tween.kill()
	Hit_tween = create_tween()
	
	Hit_tween.tween_property(sprite_2d, "modulate", Target_color, effect_Speed * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
	Hit_tween.tween_property(sprite_2d, "modulate", Color.WHITE, effect_Speed * 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func TakeDamage(amount: float) -> void:
	#// Well of course make them take damage \\#
	if not health_bar.visible:
		health_bar.visible = true
	Health -= amount
	HitEffect(0.2)
	if Health <= 0 and not _dead:
		_dead = true
		GameManager.score += 1
		queue_free.call_deferred()

	
	print(Health)

	if Health <= 0:
		queue_free.call_deferred()

func _physics_process(_delta: float) -> void:
	#// Chase the player \\#
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
		if player == null:
			return
	velocity = (player.global_position - global_position).normalized() * MoveSpeed
	move_and_slide()
	#// Deal contact damage to the player on touch (player throttles via i-frames) \\#
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider and collider.is_in_group("Player") and collider.has_method("TakeDamage"):
			collider.TakeDamage(ContactDamage)
