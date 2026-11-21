extends CharacterBody2D
class_name Player

var walk_speed: float
var shoot_slowdown_multiplier: float

var sprite: AnimatedSprite2D
var input_comp: InputComponent
var movement_state_machine: MovementStateMachine
var shooting_component: ShootingComponent
var reload_component: ReloadComponent
var health_component: HealthComponent
var damage_flash_component: DamageFlashComponent
var status_effect_manager: StatusEffectManager
var cursor_component: CursorComponent

var dash_component: DashComponent          # НОВОЕ: вынесенный компонент

var facing_direction: Vector2 = Vector2.DOWN
var movement_multiplier: float = 1.0
var aim_direction: Vector2 = Vector2.DOWN

func _ready() -> void:
	sprite = get_node("AnimatedSprite2D")
	input_comp = get_node("InputComponent")
	movement_state_machine = get_node("MovementStateMachine")
	shooting_component = get_node("ShootingComponent")
	reload_component = get_node("ReloadComponent")
	health_component = get_node("HealthComponent")
	status_effect_manager = get_node("StatusEffectManager")
	damage_flash_component = get_node_or_null("DamageFlashComponent")
	cursor_component = get_node_or_null("CursorComponent")
	dash_component = get_node_or_null("DashComponent")

	if not sprite or not input_comp or not movement_state_machine:
		push_error("Не удалось найти базовые компоненты игрока! Проверь PlayerBuilder.")

func _physics_process(_delta: float) -> void:
	if input_comp.direction != Vector2.ZERO:
		facing_direction = input_comp.direction
	move_and_slide()

# --- Делегирование дэша в компонент ---

func can_dash() -> bool:
	return dash_component != null and dash_component.can_dash()

func use_dash_charge() -> bool:
	return dash_component != null and dash_component.use_dash_charge()

# --- Универсальные геттеры (остаются) ---

func get_component(component_name: String) -> Node:
	return get_node_or_null(component_name)

func get_effective_speed(base_speed: float) -> float:
	var speed = base_speed * movement_multiplier
	if shooting_component.is_shooting:
		speed *= shoot_slowdown_multiplier
	return speed

func apply_movement_multiplier(multiplier: float) -> void:
	movement_multiplier *= multiplier

func remove_movement_multiplier() -> void:
	movement_multiplier = 1.0

# --- Респавн ---

func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position

	health_component.hp = health_component.max_hp
	health_component.shield = health_component.max_shield
	health_component.hp_changed.emit(health_component.hp, health_component.max_hp)
	health_component.shield_changed.emit(health_component.shield, health_component.max_shield)

	shooting_component.current_ammo = shooting_component.max_ammo
	shooting_component.ammo_changed.emit(shooting_component.current_ammo, shooting_component.max_ammo)

	reload_component.current_phase = reload_component.ReloadPhase.IDLE
	reload_component.reload_progress = 0.0

	if dash_component:
		dash_component.reset()
	shooting_component.fire_cooldown = 0.0

	for effect_name in status_effect_manager.active_effects.keys():
		status_effect_manager.remove_effect(effect_name)

	movement_state_machine.transition_to("IdleState")

func get_dash_charge_ratio() -> float:
	return dash_component.get_charge_ratio() if dash_component else 0.0

func get_recharge_progress() -> float:
	return dash_component.get_recharge_progress() if dash_component else 0.0

# --- Анимация (без изменений) ---

func update_animation(prefix: String) -> void:
	if sprite == null:
		sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		push_error("КРИТИЧЕСКАЯ ОШИБКА: Узел AnimatedSprite2D не найден!")
		return

	var suffix = get_direction_suffix()
	var anim_name = prefix + suffix

	if facing_direction.x < 0 and suffix != "down" and suffix != "top":
		sprite.flip_h = true
	else:
		sprite.flip_h = false

	if sprite.animation != anim_name:
		sprite.play(anim_name)

func get_direction_suffix() -> String:
	var dir = facing_direction
	var abs_x = abs(dir.x)
	var abs_y = abs(dir.y)

	if abs_x > abs_y * 1.5:
		return "side"
	elif abs_y > abs_x * 1.5:
		return "top" if dir.y < 0 else "down"
	else:
		return "side_top" if dir.y < 0 else "side_down"
