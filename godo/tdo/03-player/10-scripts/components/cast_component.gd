extends Node
class_name CastComponent

var player: Player
var cast_cooldown: float = 0.0

@export var cast_rate: float = 0.8
@export var damage: int = 25
@export var projectile_speed: float = 300.0
@export var projectile_lifetime: float = 3.0
@export var spawn_offset: float = 10.0

signal cast_performed

const PROJECTILE_BUILDER = preload("res://05-projectiles/projectile_builder.gd")

func _ready() -> void:
	player = get_parent() as Player

func _process(delta: float) -> void:
	if cast_cooldown > 0:
		cast_cooldown -= delta

func try_cast(aim_direction: Vector2) -> bool:
	if cast_cooldown > 0:
		return false
	if aim_direction == Vector2.ZERO:
		return false
	
	cast_cooldown = cast_rate
	cast_performed.emit()
	
	var spawn_pos := player.global_position + aim_direction.normalized() * spawn_offset
	#var fireball := PROJECTILE_BUILDER.spawn_fireball(spawn_pos, aim_direction, damage, projectile_speed, projectile_lifetime)
	
	# Collision layers для заклинания
	#fireball.collision_layer = 32   # слой "player_spells"
	#fireball.collision_mask = 4     # слой "enemies/hurtboxes"
	
	#get_tree().current_scene.add_child(fireball)
	
	return true
