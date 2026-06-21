extends CharacterBody2D

var SPEED = 300.0
var SetSpeed: float

var MAXSPEED = 600.0

var Accel = 1800
var Friction = 1300
var isSprinting = false

@onready var weapon_anchor: Node2D = $WeaponAnchor
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D




@onready var fist_anchor: Area2D = $FistAnchor
@onready var ray_cast_2d: RayCast2D = $FistAnchor/RayCast2D
var canAttack = true

func _ready() -> void:
	SetSpeed = SPEED

func _physics_process(delta: float) -> void:
	#// Movement \\#
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	

	
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
		velocity = velocity.move_toward(dir * SPEED, Accel * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, Friction * delta)
	#// roation \\#
	var MousePos = get_global_mouse_position()
	var MouseAngle = global_position.angle_to_point(MousePos)
	
	fist_anchor.rotation = MouseAngle
	
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
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && canAttack:
		Punch()
	

func Punch() -> void:
	canAttack = false
	print(canAttack)
	#// The collsion \\#
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		
		if collider.is_in_group("Enemy"):
			if collider.has_method("TakeDamage"):
				var PlayerDamage = GameManager.GunStats["Damage"]
				var Reload = GameManager.GunStats["Reload"]
				
				collider.TakeDamage(PlayerDamage)
				
				await get_tree().create_timer(Reload).timeout
				
	canAttack = true
