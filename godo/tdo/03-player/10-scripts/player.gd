extends CharacterBody2D
class_name Player

var walk_speed: float
var dash_speed: float
var shoot_slowdown_multiplier: float # Замедление при стрельбе

# --- Система зарядов дэша ---
var max_dashes: int
var current_dashes: int

var dash_recharge_time: float
var dash_cooldown_duration: float # кд между зарядами считаетя с конца дэша

var dash_cooldown_timer: float # Кулдаун между использованиями
var recharge_timer: float # Таймер восстановления заряда

var drop_dash_recharge_progress: bool = false

var sprite: AnimatedSprite2D
var input_comp: Node
var movement_state_machine: Node
var shooting_component: Node
var reload_component: Node
var health_component: Node
var damage_flash_component: Node
var status_effect_manager: Node

var facing_direction: Vector2 = Vector2.DOWN
var movement_multiplier: float = 1.0 # Множитель от статус-эффектов

func _ready() -> void:
	sprite = get_node("AnimatedSprite2D")
	input_comp = get_node("InputComponent")
	movement_state_machine = get_node("MovementStateMachine")
	shooting_component = get_node("ShootingComponent")
	reload_component = get_node("ReloadComponent")
	health_component = get_node("HealthComponent")
	status_effect_manager = get_node("StatusEffectManager")
	damage_flash_component = get_node_or_null("DamageFlashComponent")
	
	if not sprite or not input_comp or not movement_state_machine:
		push_error("Не удалось найти базовые компоненты игрока! Проверь PlayerBuilder.")
		
	current_dashes = max_dashes	
func _physics_process(delta: float) -> void:
	# --- НОВОЕ: Логика зарядов дэша ---
	# 1. Уменьшаем кулдаун между использованиями
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	# 2. Восстанавливаем заряды, если есть свободные слоты
	if current_dashes < max_dashes:
		recharge_timer += delta
		if recharge_timer >= dash_recharge_time:
			recharge_timer = 0.0
			current_dashes += 1
			print("Dash charge restored! Current: ", current_dashes, "/", max_dashes)
	
	# Движение
	if input_comp.direction != Vector2.ZERO:
		facing_direction = input_comp.direction
	
	move_and_slide()

# --- НОВОЕ: Метод для использования заряда ---
func use_dash_charge() -> bool:
	if current_dashes > 0:
		current_dashes -= 1
		if drop_dash_recharge_progress:
			recharge_timer = 0.0  # Сбрасываем прогресс восстановления
		print("Dash used! Charges remaining: ", current_dashes, "/", max_dashes)
		return true
	return false

# --- НОВОЕ: Геттеры для UI ---
func get_dash_charge_ratio() -> float:
	return float(current_dashes) / max_dashes

func get_recharge_progress() -> float:
	if current_dashes >= max_dashes:
		return 1.0
	return recharge_timer / dash_recharge_time
	
# --- GODOT NATIVE DI: Универсальный геттер для компонентов ---
func get_component(component_name: String) -> Node:
	return get_node_or_null(component_name)

func get_effective_speed(base_speed: float) -> float:
	var speed = base_speed * movement_multiplier
	
	# Замедление при стрельбе
	if shooting_component.is_shooting:
		speed *= shoot_slowdown_multiplier
	
	return speed

func apply_movement_multiplier(multiplier: float) -> void:
	movement_multiplier *= multiplier

func remove_movement_multiplier() -> void:
	movement_multiplier = 1.0 # Сброс (упрощенно, в реальности нужно учитывать все эффекты)

# Возрождение на чекпоинте
func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	
	# Сбрасываем здоровье
	health_component.hp = health_component.max_hp
	health_component.shield = health_component.max_shield
	health_component.hp_changed.emit(health_component.hp, health_component.max_hp)
	health_component.shield_changed.emit(health_component.shield, health_component.max_shield)
	
	# Сбрасываем патроны
	shooting_component.current_ammo = shooting_component.max_ammo
	shooting_component.ammo_changed.emit(shooting_component.current_ammo, shooting_component.max_ammo)
	
	# Сбрасываем перезарядку
	reload_component.current_phase = reload_component.ReloadPhase.IDLE
	reload_component.reload_progress = 0.0
	
	# Сбрасываем кулдауны
	dash_cooldown_timer = 0.0
	shooting_component.fire_cooldown = 0.0
	
	# Очищаем статус-эффекты
	for effect_name in status_effect_manager.active_effects.keys():
		status_effect_manager.remove_effect(effect_name)
	
	# Возвращаем в Idle
	movement_state_machine.transition_to("IdleState")

# --- Проверяем все условия для дэша ---
func can_dash() -> bool:
	# Условие 1: Заряды есть
	if current_dashes <= 0:
		return false
	
	# Условие 2: Кулдаун между дэшами прошёл
	if dash_cooldown_timer > 0:
		return false
	
	# Условие 3: Мы НЕ в DashState (не тратим заряд впустую)
	var current_state = movement_state_machine.current_state
	if current_state != null and current_state.name == "DashState":
		return false
	
	return true


func update_animation(prefix: String):
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
		if dir.y < 0:
			return "side_top"
		else:
			return "side_down"
