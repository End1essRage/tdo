extends Node2D
class_name DummyBuilder

@export_group("Dummy")
@export var custom_sprite_frames: SpriteFrames
@export var idle_animation: StringName = &"idle_down"
@export var max_hp: int = 500
@export var max_shield: int = 0
@export var respawn_delay: float = 1.5
@export var body_size: Vector2 = Vector2(14, 14)
@export var hurtbox_size: Vector2 = Vector2(16, 22)
@export var track_dps: bool = true

@export_group("Collision")
@export_flags_2d_physics var body_layer: int = 4      # слой "enemies"
@export_flags_2d_physics var body_mask: int = 1
@export_flags_2d_physics var hurtbox_layer: int = 8   # слой "hurtboxes"
@export_flags_2d_physics var hurtbox_mask: int = 0

@export_group("UI")
@export var ui_palette: UIPalette
@export var show_health_bar: bool = true
@export var show_damage_numbers: bool = true
@export var bar_offset_y: float = -18.0
@export var bar_always_visible: bool = true   # манекену удобно всегда видеть HP

const DUMMY_SCRIPT = preload("res://04-enemies/00-dummy/dummy.gd")
const HURTBOX_SCRIPT = preload("res://11-scripts/hurtbox.gd")
const HEALTH_SCRIPT = preload("res://11-scripts/10-components/health_component.gd")
const FLASH_SCRIPT = preload("res://11-scripts/10-components/damage_flash_component.gd")
const BAR_SCRIPT = preload("res://20-ui/enemy_health_bar.gd")
const NUMBERS_SCRIPT = preload("res://20-ui/damage_numbers_component.gd")

func _ready() -> void:
	add_child(build_dummy())

func build_dummy() -> CharacterBody2D:
	var dummy := CharacterBody2D.new()
	dummy.name = "TrainingDummy"
	dummy.set_script(DUMMY_SCRIPT)
	dummy.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	dummy.respawn_delay = respawn_delay
	dummy.track_dps = track_dps
	dummy.collision_layer = body_layer
	dummy.collision_mask = body_mask
	dummy.add_to_group("enemies")

	var sprite := AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if custom_sprite_frames:
		sprite.sprite_frames = custom_sprite_frames
		if sprite.sprite_frames.has_animation(idle_animation):
			sprite.play(idle_animation)
	dummy.add_child(sprite)

	var body_col := CollisionShape2D.new()
	body_col.name = "CollisionShape2D"
	var rect := RectangleShape2D.new()
	rect.size = body_size
	body_col.shape = rect
	dummy.add_child(body_col)

	# Hurtbox
	var hurtbox := Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.set_script(HURTBOX_SCRIPT)
	hurtbox.collision_layer = hurtbox_layer
	hurtbox.collision_mask = hurtbox_mask
	hurtbox.monitorable = true
	var hb_col := CollisionShape2D.new()
	var hb_rect := RectangleShape2D.new()
	hb_rect.size = hurtbox_size
	hb_col.shape = hb_rect
	hurtbox.add_child(hb_col)
	dummy.add_child(hurtbox)
	hurtbox.entity = dummy

	# Health (общий с игроком)
	var health := Node.new()
	health.name = "HealthComponent"
	health.set_script(HEALTH_SCRIPT)
	health.max_hp = max_hp
	health.max_shield = max_shield
	health.shield_regen_enabled = max_shield > 0
	health.block_regen_on_shot = false
	health.free_owner_on_death = false
	dummy.add_child(health)

	# Flash (общий с игроком)
	var flash := Node.new()
	flash.name = "DamageFlashComponent"
	flash.set_script(FLASH_SCRIPT)
	dummy.add_child(flash)

	if show_health_bar:
		var bar := Node2D.new()
		bar.name = "EnemyHealthBar"
		bar.set_script(BAR_SCRIPT)
		bar.offset_y = bar_offset_y
		bar.hide_when_full = not bar_always_visible
		if ui_palette:
			bar.palette = ui_palette
		dummy.add_child(bar)

	if show_damage_numbers:
		var numbers := Node.new()
		numbers.name = "DamageNumbersComponent"
		numbers.set_script(NUMBERS_SCRIPT)
		if ui_palette:
			numbers.palette = ui_palette
		dummy.add_child(numbers)

	return dummy
