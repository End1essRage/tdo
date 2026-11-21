extends Node2D
class_name DummyBuilder

@export var cfg: DummyConfig
@export var bar_cfg: EnemyHpBarConfig

func _ready() -> void:
	add_child(build_dummy())

func build_dummy() -> CharacterBody2D:
	var dummy := CharacterBody2D.new()
	dummy.name = "TrainingDummy"
	dummy.set_script(DUMMY_SCRIPT)
	dummy.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	dummy.respawn_delay = cfg.respawn_delay
	dummy.track_dps = cfg.track_dps
	dummy.collision_layer = cfg.body_layer
	dummy.collision_mask = cfg.body_mask
	dummy.add_to_group("enemies")

	ComponentFactory.attach_sprite(
		dummy, "AnimatedSprite2D", cfg.custom_sprite_frames, cfg.idle_animation
	)
	dummy.idle_animation = cfg.idle_animation
	dummy.on_hit_animation = cfg.on_hit_animation
	
	
	ComponentFactory.attach_rect_collision(
		dummy, "CollisionShape2D", cfg.body_size
	)

	_attach_hurtbox(dummy)

	ComponentFactory.attach_node(dummy, "HealthComponent", HEALTH_SCRIPT, {
		"max_hp": cfg.max_hp,
		"max_shield": cfg.max_shield,
		"shield_regen_enabled": cfg.max_shield > 0,
		"block_regen_on_shot": false,
		"free_owner_on_death": false,
	})
	ComponentFactory.attach_node(dummy, "DamageFlashComponent", FLASH_SCRIPT)

	if cfg.show_health_bar:
		if bar_cfg == null:
			bar_cfg = EnemyHpBarConfig.new()
			
		ComponentFactory.attach_node2d(
			dummy, "EnemyHealthBar", BAR_SCRIPT, {
				"cfg": bar_cfg
			}
		)

	if cfg.show_damage_numbers:
		var numbers := ComponentFactory.attach_node(
			dummy, "DamageNumbersComponent", NUMBERS_SCRIPT
		)
		if bar_cfg.palette:
			numbers.palette = bar_cfg.palette

	return dummy

func _attach_hurtbox(dummy: CharacterBody2D) -> void:
	var hurtbox := ComponentFactory.attach_area2d(dummy, "Hurtbox", HURTBOX_SCRIPT, {
		"collision_layer": cfg.hurtbox_layer,
		"collision_mask": cfg.hurtbox_mask,
		"monitorable": true,
	})
	ComponentFactory.attach_rect_collision(hurtbox, "CollisionShape2D", cfg.hurtbox_size)
	hurtbox.entity = dummy
	
const DUMMY_SCRIPT = preload("res://20-scripts/20-enemies/00-dummy/dummy.gd")
const HURTBOX_SCRIPT = preload("res://20-scripts/11-components/hurtbox.gd")
const HEALTH_SCRIPT = preload("res://20-scripts/11-components/health_component.gd")
const FLASH_SCRIPT = preload("res://20-scripts/11-components/damage_flash_component.gd")
const BAR_SCRIPT = preload("res://20-scripts/30-ui/enemy_health_bar.gd")
const NUMBERS_SCRIPT = preload("res://20-scripts/30-ui/damage_numbers_component.gd")
