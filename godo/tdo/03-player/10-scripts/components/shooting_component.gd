extends Node
class_name ShootingComponent

var player: Player
var is_shooting: bool = false
var fire_cooldown: float = 0.0
@export var fire_rate: float = 0.2
@export var max_ammo: int = 30
var current_ammo: int

signal shot_fired
signal ammo_changed(current: int, maximum: int)

func _ready() -> void:
	player = get_parent()
	current_ammo = max_ammo

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta
	else:
		is_shooting = false

func try_shoot() -> bool:
	if fire_cooldown > 0 or current_ammo <= 0:
		return false
	
	is_shooting = true
	fire_cooldown = fire_rate
	current_ammo -= 1
	ammo_changed.emit(current_ammo, max_ammo)
	shot_fired.emit()
	return true

func reload_ammo() -> void:
	current_ammo = max_ammo
	ammo_changed.emit(current_ammo, max_ammo)
