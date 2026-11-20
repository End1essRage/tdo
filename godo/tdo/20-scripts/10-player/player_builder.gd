extends Node2D
class_name PlayerBuilder

@export var config: GameConfig

const PLAYER_SCRIPT = preload("res://20-scripts/10-player/player.gd")
const INPUT_SCRIPT = preload("res://20-scripts/10-player/input_component.gd")
const MOVEMENT_STATE_MACHINE_SCRIPT = preload("res://20-scripts/10-player/movement_fsm.gd")
const IDLE_STATE_SCRIPT = preload("res://20-scripts/10-player/movement-states/idle.gd")
const WALK_STATE_SCRIPT = preload("res://20-scripts/10-player/movement-states/walk.gd")
const DASH_STATE_SCRIPT = preload("res://20-scripts/10-player/movement-states/dash.gd")

const SHOOTING_COMPONENT_SCRIPT = preload("res://20-scripts/10-player/components/shooting_component.gd")
const RELOAD_COMPONENT_SCRIPT = preload("res://20-scripts/10-player/components/reload_component.gd")
const HEALTH_COMPONENT_SCRIPT = preload("res://20-scripts/health_component.gd")
const DAMAGE_FLASH_COMPONENT_SCRIPT = preload("res://20-scripts/damage_flash_component.gd")
const STATUS_EFFECT_MANAGER_SCRIPT = preload("res://20-scripts/10-player/status-effects/manager.gd")
const PLAYER_UI_SCRIPT = preload("res://20-scripts/30-ui/player_ui.gd")

const CURSOR_COMPONENT_SCRIPT = preload("res://20-scripts/12-cursor/cursor_component.gd")
const CAST_COMPONENT_SCRIPT = preload("res://20-scripts/10-player/components/cast_component.gd")

const DASH_CHARGES_UI_SCRIPT = preload("res://20-scripts/30-ui/dash_charges_ui.gd")
const PROJECTILE_BUILDER_SCRIPT = preload("res://20-scripts/15-projectiles/projectile_builder.gd")

const CAMERA_SCRIPT = preload("res://20-scripts/camera.gd")
const DEFAULT_CONFIG = preload("res://00-config/default.tres")

func _ready() -> void:
	if config == null:
		config = DEFAULT_CONFIG
	
	print("--- Сборка игрока начата ---")
	var player = build_player()
	add_child(player)
	print("--- Игрок успешно создан! ---")

func build_player() -> CharacterBody2D:
	var player = CharacterBody2D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	
	player.walk_speed = config.player_speed
	player.dash_speed = config.player_dash_speed
	player.dash_cooldown_duration = config.dash_cooldown_duration
	player.shoot_slowdown_multiplier = config.shoot_slowdown_multiplier # НОВОЕ!
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	
	player.max_dashes = config.max_dashes
	player.dash_recharge_time = config.dash_recharge_time
	player.dash_cooldown_duration = config.dash_cooldown_duration
	
	player.add_to_group("player")
	
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if config.custom_sprite_frames:
		sprite.sprite_frames = config.custom_sprite_frames
	player.add_child(sprite)
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(12, 12)
	collision.shape = shape
	player.add_child(collision)
	
	var input_comp = Node2D.new()
	input_comp.name = "InputComponent"
	input_comp.set_script(INPUT_SCRIPT)
	player.add_child(input_comp)
	
	var movement_state_machine = Node.new()
	movement_state_machine.name = "MovementStateMachine"
	movement_state_machine.set_script(MOVEMENT_STATE_MACHINE_SCRIPT)
	player.add_child(movement_state_machine)
	
	_create_state(movement_state_machine, "IdleState", IDLE_STATE_SCRIPT)
	_create_state(movement_state_machine, "WalkState", WALK_STATE_SCRIPT)
	_create_state(movement_state_machine, "DashState", DASH_STATE_SCRIPT, {"dash_duration": config.dash_duration})
	
	#_create_component(player, "ShootingComponent", SHOOTING_COMPONENT_SCRIPT)
	_create_component(player, "CastComponent", CAST_COMPONENT_SCRIPT)
	_create_component(player, "ReloadComponent", RELOAD_COMPONENT_SCRIPT)
	_create_component(player, "HealthComponent", HEALTH_COMPONENT_SCRIPT)
	_create_component(player, "DamageFlashComponent", DAMAGE_FLASH_COMPONENT_SCRIPT)
	_create_component(player, "StatusEffectManager", STATUS_EFFECT_MANAGER_SCRIPT)
	
	# --- Камера  ---
	var camera = Camera2D.new()
	camera.name = "Camera2D"
	camera.set_script(CAMERA_SCRIPT)
	add_child(camera)
	
	# --- Курсор  ---
	var cursor_component = Node2D.new()
	cursor_component.name = "CursorComponent"
	cursor_component.set_script(CURSOR_COMPONENT_SCRIPT)
	player.add_child(cursor_component)
	
	# --- Инстансим UI  ---
	var player_ui = Node2D.new()
	player_ui.name = "PlayerUI"
	player_ui.set_script(PLAYER_UI_SCRIPT)
	if config.ui_palette:
		player_ui.palette = config.ui_palette  # Передаём палитру в скрипт
	player.add_child(player_ui)
	
	var dash_ui = Node2D.new()
	dash_ui.name = "DashChargesUI"
	dash_ui.set_script(DASH_CHARGES_UI_SCRIPT)
	if config.ui_palette:
		dash_ui.palette = config.ui_palette  # Передаём палитру в скрипт
	player.add_child(dash_ui)
	
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
		
	return player

func _create_state(parent: Node, state_name: String, script_path: Script, overrides: Dictionary = {}) -> void:
	var state = Node.new()
	state.name = state_name
	state.set_script(script_path)
	for key in overrides:
		state.set(key, overrides[key])
	parent.add_child(state)

func _create_component(parent: Node, component_name: String, script_path: Script) -> void:
	var component = Node.new()
	component.name = component_name
	component.set_script(script_path)
	parent.add_child(component)
