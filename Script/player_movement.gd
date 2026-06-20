extends CharacterBody2D

const SPEED = 300.0

@onready var weapon_anchor: Node2D = $WeaponAnchor

func _physics_process(delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	weapon_anchor.look_at(get_global_mouse_position())
	weapon_anchor.rotation_degrees = wrap(weapon_anchor.rotation_degrees, 0, 360)
	if(weapon_anchor.rotation_degrees > 90 and weapon_anchor.rotation_degrees < 270):
		weapon_anchor.scale.y = -1
	else:
		weapon_anchor.scale.y = 1
	
	move_and_collide(dir * SPEED * delta)
