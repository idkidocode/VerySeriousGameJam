extends Node2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D

func Attack() -> void:
	#// The collsion \\#
	if ray_cast_2d.is_colliding():
		var collider = ray_cast_2d.get_collider()
		
		if collider.is_in_group("Enemy"):
			if collider.has_method("TakeDamage"):
				var PlayerDamage = GameManager.GunStats["Damage"] * GameManager.damage_mult()
				var Reload = GameManager.GunStats["Reload"]
				
				collider.TakeDamage(PlayerDamage)
				
				await get_tree().create_timer(Reload).timeout
