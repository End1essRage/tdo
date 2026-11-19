extends Node
class_name HealthComponent

signal hp_changed(current: int, maximum: int)
signal shield_changed(current: int, maximum: int)
signal damage_taken(amount: int)                    # старый сигнал (flash)
signal damage_received(amount: int, is_crit: bool)   # для чисел урона
signal died
signal healed(amount: int)

@export_group("Health")
@export var max_hp: int = 100

@export_group("Shield")
@export var max_shield: int = 0
@export var shield_regen_delay: float = 3.0
@export var shield_regen_rate: float = 20.0
@export var shield_regen_enabled: bool = true
@export var block_regen_on_shot: bool = false   # true только у игрока

@export_group("Behavior")
@export var hit_invulnerability: float = 0.0    # микро-iframe после попадания
@export var free_owner_on_death: bool = false   # враг удаляется, манекен — нет

var host: Node
var hp: int
var shield: int
var is_dead: bool = false
var is_invulnerable: bool = false               # ручной флаг (дэш, парирование)

var regen_timer: float = 0.0
var _regen_accum: float = 0.0
var _hit_invuln_timer: float = 0.0

func _ready() -> void:
	host = get_parent()
	hp = max_hp
	shield = max_shield

	# Опциональная зависимость: есть ShootingComponent — блокируем реген при стрельбе
	if block_regen_on_shot:
		var sc = host.get_node_or_null("ShootingComponent")
		if sc != null and sc.has_signal("shot_fired"):
			sc.shot_fired.connect(_on_action_performed)

	hp_changed.emit(hp, max_hp)
	shield_changed.emit(shield, max_shield)

func _process(delta: float) -> void:
	if _hit_invuln_timer > 0.0:
		_hit_invuln_timer -= delta

	if regen_timer > 0.0:
		regen_timer -= delta
		return

	if shield_regen_enabled and max_shield > 0 and shield < max_shield and not is_dead:
		_regen_accum += shield_regen_rate * delta
		var add := int(_regen_accum)
		if add > 0:
			_regen_accum -= float(add)
			shield = mini(shield + add, max_shield)
			shield_changed.emit(shield, max_shield)

func can_take_damage() -> bool:
	return not is_dead and not is_invulnerable and _hit_invuln_timer <= 0.0

# Возвращает реально нанесённый урон (0 если заблокировано)
func take_damage(amount: int, is_crit: bool = false) -> int:
	if amount <= 0 or not can_take_damage():
		return 0

	var remaining := amount
	var applied := 0

	if shield > 0:
		var to_shield := mini(shield, remaining)
		shield -= to_shield
		remaining -= to_shield
		applied += to_shield
		shield_changed.emit(shield, max_shield)

	if remaining > 0 and hp > 0:
		var to_hp := mini(hp, remaining)
		hp -= to_hp
		applied += to_hp
		hp_changed.emit(hp, max_hp)

	if hit_invulnerability > 0.0:
		_hit_invuln_timer = hit_invulnerability

	regen_timer = shield_regen_delay
	damage_taken.emit(applied)
	damage_received.emit(applied, is_crit)

	if hp <= 0 and not is_dead:
		is_dead = true
		died.emit()
		if free_owner_on_death:
			host.queue_free()

	return applied

func heal(amount: int) -> void:
	if is_dead or amount <= 0:
		return
	var before := hp
	hp = mini(hp + amount, max_hp)
	if hp != before:
		hp_changed.emit(hp, max_hp)
		healed.emit(hp - before)

func set_invulnerable(value: bool) -> void:
	is_invulnerable = value

func reset() -> void:
	is_dead = false
	is_invulnerable = false
	_hit_invuln_timer = 0.0
	regen_timer = 0.0
	_regen_accum = 0.0
	hp = max_hp
	shield = max_shield
	hp_changed.emit(hp, max_hp)
	shield_changed.emit(shield, max_shield)

func _on_action_performed() -> void:
	regen_timer = shield_regen_delay
