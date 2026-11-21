extends Node2D
class_name PlayerBuilder

@export var config: PlayerConfig

func _ready() -> void:
	if config == null:
		config = DEFAULT_CONFIG
	
	var player = build_player()
	add_child(player)
	
func apply_cfg(player: Player) -> void:
	player.walk_speed = config.player_speed
	#player.dash_speed = config.player_dash_speed
	player.shoot_slowdown_multiplier = config.shoot_slowdown_multiplier
	
func build_player() -> CharacterBody2D:
	var player := CharacterBody2D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	apply_cfg(player)
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	player.add_to_group("player")

	ComponentFactory.attach_sprite(
		player, "AnimatedSprite2D", config.custom_sprite_frames
	)
	ComponentFactory.attach_rect_collision(
		player, "CollisionShape2D", Vector2(12, 12)
	)

	ComponentFactory.attach_node2d(player, "InputComponent", INPUT_SCRIPT)

	var fsm := ComponentFactory.attach_node(
		player, "MovementStateMachine", MOVEMENT_STATE_MACHINE_SCRIPT
	)
	ComponentFactory.attach_state(fsm, "IdleState", IDLE_STATE_SCRIPT)
	ComponentFactory.attach_state(fsm, "WalkState", WALK_STATE_SCRIPT)
	ComponentFactory.attach_state(fsm, "DashState", DASH_STATE_SCRIPT, {
		"dash_duration": config.dash_duration
	})

	ComponentFactory.attach_node(player, "ReloadComponent", RELOAD_COMPONENT_SCRIPT)
	ComponentFactory.attach_node(player, "HealthComponent", HEALTH_COMPONENT_SCRIPT)
	ComponentFactory.attach_node(player, "DamageFlashComponent", DAMAGE_FLASH_COMPONENT_SCRIPT)
	ComponentFactory.attach_node(player, "StatusEffectManager", STATUS_EFFECT_MANAGER_SCRIPT)
	ComponentFactory.attach_node(player, "DashComponent", DASH_COMPONENT_SCRIPT, {
		"max_dashes":                    config.max_dashes,
		"recharge_time":                 config.dash_recharge_time,
		"cooldown_duration":             config.dash_cooldown_duration,
		"dash_speed": 					 config.player_dash_speed,
		"drop_recharge_progress_on_use": false,
	})
	
	# --- Камера  ---
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.set_script(CAMERA_SCRIPT)
	add_child(camera)
	
	# --- Курсор  ---
	ComponentFactory.attach_node2d(player, "CursorComponent", CURSOR_COMPONENT_SCRIPT)
	
	_attach_ui(player,config)
	_attach_shooting_component(player)
		
	return player

func _attach_ui(player: CharacterBody2D, cfg: PlayerConfig) -> void:
	var hud := Node2D.new()
	hud.name = "PlayerHUD"
	hud.set_script(PLAYER_HUD_SCRIPT)
	if cfg.ui_palette:
		hud.palette = cfg.ui_palette
	player.add_child(hud)

func _attach_shooting_component(player:CharacterBody2D) -> void:
	# --- Создаём фабрику партиклов ---
	var projectile_builder = Node.new()
	projectile_builder.name = "ProjectileBuilder"
	projectile_builder.set_script(PROJECTILE_BUILDER_SCRIPT)
	player.add_child(projectile_builder)

	# Передаём сцену пули из инспектора (если задана)
	if config.bullet_scene != null:
		print("bullet_scene != null")
		projectile_builder.set_bullet_scene(config.bullet_scene)
	else:
		print("PlayerBuilder: Bullet Scene не назначен, используется дефолтная пуля")
		
	# --- Создаём компонент стрельбы ---
	var shooting_comp = Node.new()
	shooting_comp.name = "ShootingComponent"
	shooting_comp.set_script(SHOOTING_COMPONENT_SCRIPT)
	player.add_child(shooting_comp)

	# Связываем ShootingComponent с ProjectileBuilder
	shooting_comp.projectile_builder = projectile_builder
	
	if config:
		var impact_path = ""
		if config.current_impact_index < config.impact_effects.size():
			impact_path = config.impact_effects[config.current_impact_index]
		
		shooting_comp.impact_frames_path = impact_path
		shooting_comp.impact_anim_speed = config.impact_anim_speed
		shooting_comp.damage = config.projectile_damage
		shooting_comp.bullet_speed = config.projectile_speed
		shooting_comp.bullet_lifetime = config.projectile_lifetime

const PLAYER_SCRIPT = preload("res://20-scripts/10-player/player.gd")
const INPUT_SCRIPT = preload("res://20-scripts/10-player/input_component.gd")
const MOVEMENT_STATE_MACHINE_SCRIPT = preload("res://20-scripts/10-player/movement_fsm.gd")
const IDLE_STATE_SCRIPT = preload("res://20-scripts/10-player/movement-states/idle.gd")
const WALK_STATE_SCRIPT = preload("res://20-scripts/10-player/movement-states/walk.gd")
const DASH_STATE_SCRIPT = preload("res://20-scripts/10-player/movement-states/dash.gd")

const SHOOTING_COMPONENT_SCRIPT = preload("res://20-scripts/10-player/components/shooting_component.gd")
const DASH_COMPONENT_SCRIPT = preload("res://20-scripts/10-player/components/dash_component.gd")
const RELOAD_COMPONENT_SCRIPT = preload("res://20-scripts/10-player/components/reload_component.gd")
const HEALTH_COMPONENT_SCRIPT = preload("res://20-scripts/11-components/health_component.gd")
const DAMAGE_FLASH_COMPONENT_SCRIPT = preload("res://20-scripts/11-components/damage_flash_component.gd")
const STATUS_EFFECT_MANAGER_SCRIPT = preload("res://20-scripts/11-components/status-effects/manager.gd")
const PLAYER_UI_SCRIPT = preload("res://20-scripts/30-ui/10-player-hud/player_ui.gd")
const PLAYER_HUD_SCRIPT = preload("res://20-scripts/30-ui/10-player-hud/player_hud.gd")

const CURSOR_COMPONENT_SCRIPT = preload("res://20-scripts/12-cursor/cursor_component.gd")

const DASH_CHARGES_UI_SCRIPT = preload("res://20-scripts/30-ui/dash_charges_ui.gd")
const PROJECTILE_BUILDER_SCRIPT = preload("res://20-scripts/07-factories/projectile_builder.gd")

const CAMERA_SCRIPT = preload("res://20-scripts/camera.gd")
const DEFAULT_CONFIG = preload("res://00-config/player_default.tres")
