extends Node2D
class_name PlayerBuilder

@export_group("Player Overrides")
@export var custom_sprite_frames: SpriteFrames
@export var player_speed: float = 100.0
@export var player_run_speed: float = 180.0
@export var player_dash_speed: float = 400.0
@export var dash_duration: float = 0.3
@export var dash_cooldown_duration: float = 1.5
@export var shoot_slowdown_multiplier: float = 0.7 # НОВОЕ!

const PLAYER_SCRIPT = preload("res://03-player/10-scripts/player.gd")
const INPUT_SCRIPT = preload("res://03-player/10-scripts/input_component.gd")
const MOVEMENT_STATE_MACHINE_SCRIPT = preload("res://03-player/10-scripts/movement_fsm.gd")
const IDLE_STATE_SCRIPT = preload("res://03-player/10-scripts/movement-states/idle.gd")
const WALK_STATE_SCRIPT = preload("res://03-player/10-scripts/movement-states/walk.gd")
const RUN_STATE_SCRIPT = preload("res://03-player/10-scripts/movement-states/run.gd")
const DASH_STATE_SCRIPT = preload("res://03-player/10-scripts/movement-states/dash.gd")

const SHOOTING_COMPONENT_SCRIPT = preload("res://03-player/10-scripts/components/shooting_component.gd")
const RELOAD_COMPONENT_SCRIPT = preload("res://03-player/10-scripts/components/reload_component.gd")
const HEALTH_COMPONENT_SCRIPT = preload("res://03-player/10-scripts/components/health_component.gd")
const DAMAGE_FLASH_COMPONENT_SCRIPT = preload("res://03-player/10-scripts/components/damage_flash_component.gd")
const STATUS_EFFECT_MANAGER_SCRIPT = preload("res://03-player/10-scripts/status-effects/manager.gd")
const PLAYER_UI_SCRIPT = preload("res://03-player/10-scripts/ui/player_ui.gd")

func _ready() -> void:
	print("--- Сборка игрока начата ---")
	var player = build_player()
	add_child(player)
	print("--- Игрок успешно создан! ---")

func build_player() -> CharacterBody2D:
	var player = CharacterBody2D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	
	player.walk_speed = player_speed
	player.run_speed = player_run_speed
	player.dash_speed = player_dash_speed
	player.dash_cooldown_duration = dash_cooldown_duration
	player.shoot_slowdown_multiplier = shoot_slowdown_multiplier # НОВОЕ!
	player.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	player.add_to_group("player")
	
	var sprite = AnimatedSprite2D.new()
	sprite.name = "AnimatedSprite2D"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if custom_sprite_frames:
		sprite.sprite_frames = custom_sprite_frames
	player.add_child(sprite)
	
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(12, 12)
	collision.shape = shape
	player.add_child(collision)
	
	var input_comp = Node.new()
	input_comp.name = "InputComponent"
	input_comp.set_script(INPUT_SCRIPT)
	player.add_child(input_comp)
	
	var movement_state_machine = Node.new()
	movement_state_machine.name = "MovementStateMachine"
	movement_state_machine.set_script(MOVEMENT_STATE_MACHINE_SCRIPT)
	player.add_child(movement_state_machine)
	
	_create_state(movement_state_machine, "IdleState", IDLE_STATE_SCRIPT)
	_create_state(movement_state_machine, "WalkState", WALK_STATE_SCRIPT)
	_create_state(movement_state_machine, "RunState", RUN_STATE_SCRIPT)
	_create_state(movement_state_machine, "DashState", DASH_STATE_SCRIPT, {"dash_duration": dash_duration})
	
	_create_component(player, "ShootingComponent", SHOOTING_COMPONENT_SCRIPT)
	_create_component(player, "ReloadComponent", RELOAD_COMPONENT_SCRIPT)
	_create_component(player, "HealthComponent", HEALTH_COMPONENT_SCRIPT)
	_create_component(player, "DamageFlashComponent", DAMAGE_FLASH_COMPONENT_SCRIPT)
	_create_component(player, "StatusEffectManager", STATUS_EFFECT_MANAGER_SCRIPT)
	
	# UI над головой
	var player_ui = Node2D.new()
	player_ui.name = "PlayerUI"
	player_ui.set_script(PLAYER_UI_SCRIPT)
	player.add_child(player_ui)
	
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
