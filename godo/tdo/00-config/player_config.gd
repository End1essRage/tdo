extends Resource
class_name PlayerConfig

@export_group("Player")
@export var player_speed: float = 100.0
@export var shoot_slowdown_multiplier: float = 0.7
@export var custom_sprite_frames: SpriteFrames

@export_group("Dash")
@export var max_dashes: int = 2
@export var dash_recharge_time: float = 3.0
@export var player_dash_speed: float = 400.0
@export var dash_duration: float = 0.3
@export var dash_cooldown_duration: float = 0.5

@export_group("Projectiles")
@export var bullet_scene: PackedScene
@export var projectile_speed: float = 400.0
@export var projectile_damage: int = 10
@export var projectile_lifetime: float = 2.0

@export_group("Hit Effects")
# Пути к ресурсам (можно выбирать в инспекторе через выпадающий список)
@export var impact_effects: Array[String] = [
	"res://10-assets/20-sprite-frames/17-hits/1.tres",
	"res://10-assets/20-sprite-frames/17-hits/2.tres",
	"res://10-assets/20-sprite-frames/17-hits/3.tres",
	"res://10-assets/20-sprite-frames/17-hits/4.tres",
	"res://10-assets/20-sprite-frames/17-hits/5.tres",
	"res://10-assets/20-sprite-frames/17-hits/6.tres",
]
@export var current_impact_index: int = 0 # Какой эффект сейчас выбран
@export var impact_anim_speed: float = 15.0

@export_group("UI")
@export var ui_palette: UIPalette
