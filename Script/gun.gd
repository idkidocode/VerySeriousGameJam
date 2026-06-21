extends Node2D

@onready var gunRaycast: RayCast2D = $RayCast2D
@export var hitableGroupName: String = "hitable"

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack_action"):
		gunRaycast.force_raycast_update()
		if(gunRaycast.is_colliding()):
			var collider: CharacterBody2D = gunRaycast.get_collider()
			if collider.is_in_group(hitableGroupName):
				collider.TakeDamage(GameManager.GunStats["Damage"]);
