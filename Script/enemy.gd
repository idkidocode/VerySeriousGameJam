extends CharacterBody2D

@export var MaxHealth: float = 100
@export var CurrentHealth: float = 100

func _ready() -> void:
	if CurrentHealth <= MaxHealth:
		CurrentHealth = MaxHealth

func TakeDamage(amount: float) -> void:
	CurrentHealth -= amount
	print(CurrentHealth)

func _process(_delta: float) -> void:
	if CurrentHealth <= 0:
		self.free()
