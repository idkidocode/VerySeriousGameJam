extends CharacterBody2D

var SPEED = 300.0
var isSprinting = false

@onready var weapon_anchor: Node2D = $WeaponAnchor
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
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
	
	weapon_anchor.look_at(get_global_mouse_position())
	weapon_anchor.rotation_degrees = wrap(weapon_anchor.rotation_degrees, 0, 360)
	if(weapon_anchor.rotation_degrees > 90 and weapon_anchor.rotation_degrees < 270):
		weapon_anchor.scale.y = -1
		animated_sprite_2d.scale.x = 5
	else:
		weapon_anchor.scale.y = 1
		animated_sprite_2d.scale.x = -5
	
	if Input.is_action_pressed("sprint"):
		isSprinting = true
		SPEED = 600.0
	else:
		isSprinting = false
		SPEED = 300.0
	
	move_and_collide(dir * SPEED * delta)
