extends Node


var GunStats = {
	"Damage" = 10,
	"Reload" = 0.8
}

#// Run stats \\#
var score: int = 0
var wave: int = 0

#// Currency (chips) \\#
var red_chips: int = 0
var yellow_chips: int = 0
var blue_chips: int = 0

#// Multiplicative stat bonuses from chips held (tune these rates) \\#
const RED_DAMAGE_PER_CHIP: float = 0.08      # red chips -> more damage
const YELLOW_FIRERATE_PER_CHIP: float = 0.05 # yellow chips -> faster fire/reload
const BLUE_SPEED_PER_CHIP: float = 0.05      # blue chips -> faster movement

func damage_mult() -> float:
	return 1.0 + red_chips * RED_DAMAGE_PER_CHIP

func reload_mult() -> float:
	return 1.0 / (1.0 + yellow_chips * YELLOW_FIRERATE_PER_CHIP)

func speed_mult() -> float:
	return 1.0 + blue_chips * BLUE_SPEED_PER_CHIP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
