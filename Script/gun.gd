extends Node2D

@onready var gunRaycast: RayCast2D = $RayCast2D
@export var hitableGroupName: String = "hitable"

func Attack() -> void:
	gunRaycast.force_raycast_update()
	if gunRaycast.is_colliding():
		var collider = gunRaycast.get_collider()   # untyped: could be an enemy OR a static obstacle
		if collider and collider is CharacterBody2D and collider.is_in_group(hitableGroupName) and collider.has_method("TakeDamage"):
			collider.TakeDamage(GameManager.GunStats["Damage"]);
