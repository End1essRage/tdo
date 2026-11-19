extends EnemyBase
class_name TrainingDummy

@export var respawn_delay: float = 1.5
@export var track_dps: bool = true
@export var dps_window: float = 3.0

var total_damage: int = 0
var last_damage: int = 0
var dps: float = 0.0

var _respawn_timer: float = 0.0
var _hits: Array = []   # [{ "t": float, "amount": int }]
var _time: float = 0.0

func _configure() -> void:
	add_to_group("dummy")

func _physics_process(delta: float) -> void:
	_time += delta

	if _respawn_timer > 0.0:
		_respawn_timer -= delta
		if _respawn_timer <= 0.0:
			_revive()

	if track_dps:
		while not _hits.is_empty() and _time - _hits[0]["t"] > dps_window:
			_hits.pop_front()
		var sum := 0
		for h in _hits:
			sum += h["amount"]
		dps = float(sum) / dps_window

func _on_damage_received(amount: int, is_crit: bool) -> void:
	super._on_damage_received(amount, is_crit)
	total_damage += amount
	last_damage = amount
	if track_dps:
		_hits.append({ "t": _time, "amount": amount })

func _on_died() -> void:
	super._on_died()
	_respawn_timer = respawn_delay
	if sprite:
		sprite.modulate = Color(0.3, 0.3, 0.3, 0.6)
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)

func _revive() -> void:
	health_component.reset()
	if sprite:
		sprite.modulate = Color.WHITE
	if hurtbox:
		hurtbox.set_deferred("monitoring", true)
		hurtbox.set_deferred("monitorable", true)

func reset_stats() -> void:
	total_damage = 0
	last_damage = 0
	_hits.clear()
	dps = 0.0
