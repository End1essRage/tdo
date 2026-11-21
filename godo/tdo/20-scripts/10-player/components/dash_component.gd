# res://20-scripts/10-player/components/dash_component.gd
class_name DashComponent
extends Node

signal charges_changed(current: int, maximum: int)
signal charge_used()
signal charge_restored(current: int, maximum: int)
signal cooldown_started(duration: float)
signal cooldown_finished()

@export var max_dashes: int = 2
@export var recharge_time: float = 1.5
@export var cooldown_duration: float = 0.15
@export var dash_speed: float
@export var drop_recharge_progress_on_use: bool = false

var current_dashes: int = 0
var dash_cooldown_timer: float = 0.0
var recharge_timer: float = 0.0

# Ссылка на FSM, чтобы не тратить заряд в DashState
var _movement_fsm: Node

func _ready() -> void:
	current_dashes = max_dashes
	# FSM ищется у родителя (Player)
	_movement_fsm = get_parent().get_node_or_null("MovementStateMachine") if get_parent() else null

func _physics_process(delta: float) -> void:
	# 1. Кулдаун между использованиями
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
		if dash_cooldown_timer <= 0.0:
			cooldown_finished.emit()

	# 2. Восстановление зарядов
	if current_dashes < max_dashes:
		recharge_timer += delta
		if recharge_timer >= recharge_time:
			recharge_timer = 0.0
			current_dashes += 1
			charge_restored.emit(current_dashes, max_dashes)
			charges_changed.emit(current_dashes, max_dashes)

# --- Публичный API ---

func can_dash() -> bool:
	if current_dashes <= 0:
		return false
	if dash_cooldown_timer > 0.0:
		return false
	if _movement_fsm and _movement_fsm.current_state \
			and _movement_fsm.current_state.name == "DashState":
		return false
	return true

func use_dash_charge() -> bool:
	if not can_dash():
		return false
	current_dashes -= 1
	if drop_recharge_progress_on_use:
		recharge_timer = 0.0
	charge_used.emit()
	charges_changed.emit(current_dashes, max_dashes)
	return true

	
func start_cooldown() -> void:
	dash_cooldown_timer = cooldown_duration

func reset() -> void:
	current_dashes = max_dashes
	dash_cooldown_timer = 0.0
	recharge_timer = 0.0
	charges_changed.emit(current_dashes, max_dashes)

# --- Геттеры для UI ---

func get_charge_ratio() -> float:
	if max_dashes <= 0:
		return 0.0
	return float(current_dashes) / float(max_dashes)

func get_recharge_progress() -> float:
	if current_dashes >= max_dashes:
		return 1.0
	if recharge_time <= 0.0:
		return 1.0
	return clamp(recharge_timer / recharge_time, 0.0, 1.0)

func is_on_cooldown() -> bool:
	return dash_cooldown_timer > 0.0
