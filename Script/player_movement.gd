extends CharacterBody2D

var SPEED = 300.0
var SetSpeed: float

var MAXSPEED = 600.0

var Accel = 1800
var Friction = 1300
var isSprinting = false



#// Health \\#
@export var MaxHealth: float = 100.0
var Health: float
var invincible: bool = false
@export var InvincibilityTime: float = 0.5

@onready var weapon_anchor: Node2D = $WeaponAnchor
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var canAttack = true
var CurrentWeapon: Node2D

func _ready() -> void:
	SetSpeed = SPEED
	Health = MaxHealth
	CurrentWeapon = weapon_anchor.get_child(0)
	#make the punch not loop or it screws up
	animated_sprite_2d.sprite_frames.set_animation_loop("Punch01", false)

func _physics_process(delta: float) -> void:
	#// Movement \\#
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if canAttack:
		if dir == Vector2(0, 0):
			animated_sprite_2d.play("idle")
		elif dir != Vector2(0, 0):
			if isSprinting:
				animated_sprite_2d.play("Running")
			else:
				animated_sprite_2d.play("Walking")
		else:
			animated_sprite_2d.stop()
		
	if dir != Vector2.ZERO:
		velocity = velocity.move_toward(dir * SPEED * GameManager.speed_mult(), Accel * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
	#// roation \\#
	var MousePos = get_global_mouse_position()
	var MouseAngle = global_position.angle_to_point(MousePos)
	
	weapon_anchor.rotation = MouseAngle
	
	if MousePos.x > global_position.x:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
	
	#// Extra Movement \\#
	if Input.is_action_pressed("sprint"):
		isSprinting = true
		SPEED = MAXSPEED
	else:
		isSprinting = false
		SPEED = SetSpeed
	
	move_and_slide()
	#// Attack Funcitons \\#
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && canAttack && CurrentWeapon != null :
		if canAttack:
			if CurrentWeapon.name == "Fist":
				animated_sprite_2d.stop()
				animated_sprite_2d.play("Punch01")
			CurrentWeapon.Attack()
		
		canAttack = false
		await get_tree().create_timer(GameManager.GunStats["Reload"] * GameManager.reload_mult()).timeout
		canAttack = true

#// Health \\#sss
func TakeDamage(amount: float) -> void:
	if invincible:
		return
	Health -= amount
	print("Player HP: ", Health)
	if Health <= 0:
		Die()
		return
	#// brief i-frames so contact damage doesn't drain health every frame \\#
	invincible = true
	await get_tree().create_timer(InvincibilityTime).timeout
	invincible = false

func Die() -> void:
	#// Show the game-over screen (HUD); fall back to a plain reload if the HUD isn't found. \\#
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud and hud.has_method("show_game_over"):
		hud.show_game_over()
	else:
		get_tree().reload_current_scene()
