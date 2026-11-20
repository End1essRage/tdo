extends Node
class_name ShootingComponent

var player: Player
var is_shooting: bool = false
var fire_cooldown: float = 0.0

var impact_frames_path: String = ""
var impact_anim_speed: float = 15.0

@export var fire_rate: float = 0.2
@export var max_ammo: int = 30
@export var damage: int = 10
@export var bullet_speed: float = 450.0
@export var bullet_lifetime: float = 1.5
@export var spawn_offset: float = 12.0  # Отступ от центра игрока

var current_ammo: int
var projectile_builder: Node

signal shot_fired
signal ammo_changed(current: int, maximum: int)

func _ready() -> void:
	player = get_parent() as Player
	current_ammo = max_ammo

func _process(delta: float) -> void:
	if fire_cooldown > 0:
		fire_cooldown -= delta
	else:
		is_shooting = false

func try_shoot(aim_direction: Vector2) -> bool:
	if fire_cooldown > 0 or current_ammo <= 0:
		return false
	if aim_direction == Vector2.ZERO:
		return false
		
	if projectile_builder == null:
		return false
	
	is_shooting = true
	fire_cooldown = fire_rate
	current_ammo -= 1
	ammo_changed.emit(current_ammo, max_ammo)
	shot_fired.emit()
	
	var spawn_pos := player.global_position + aim_direction.normalized() * spawn_offset
	var bullet := projectile_builder.spawn_bullet(
		spawn_pos,
		aim_direction,
		damage,
		bullet_speed,
		bullet_lifetime
	) as Projectile
	
	if bullet != null:
		# Передаем настройки импакта
		bullet.impact_frames_path = impact_frames_path
		bullet.impact_anim_speed = impact_anim_speed
		
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = spawn_pos
		bullet.direction = aim_direction.normalized()
		bullet.rotation = aim_direction.normalized().angle()
	else:
		print("❌ Пуля НЕ создана!")
		
	return true

func reload_ammo() -> void:
	current_ammo = max_ammo
	ammo_changed.emit(current_ammo, max_ammo)
