extends EnemyBase
class_name TrainingDummy

@export var respawn_delay: float = 1.5
@export var track_dps: bool = true
@export var dps_window: float = 3.0
var on_hit_animation: String = &"take_damage_l"
var idle_animation: String = &"default"

var total_damage: int = 0
var last_damage: int = 0
var dps: float = 0.0

var _respawn_timer: float = 0.0
var _hits: Array = []
var _time: float = 0.0
var _hit_anim_playing: bool = false

func _configure() -> void:
	add_to_group("dummy")
	# Подключаемся к сигналу окончания анимации спрайта
	if sprite and sprite is AnimatedSprite2D:
		if not sprite.animation_finished.is_connected(_on_sprite_animation_finished):
			sprite.animation_finished.connect(_on_sprite_animation_finished)

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

	_play_hit_animation()

func _play_hit_animation() -> void:
	if sprite == null or not (sprite is AnimatedSprite2D):
		return
	if on_hit_animation == &"":
		return
	if not sprite.sprite_frames or not sprite.sprite_frames.has_animation(on_hit_animation):
		return

	_hit_anim_playing = true
	sprite.play(on_hit_animation)

func _on_sprite_animation_finished() -> void:
	# Реагируем только если это была наша hit-анимация
	if not _hit_anim_playing:
		return
	_hit_anim_playing = false
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(idle_animation):
		sprite.play(idle_animation)

func _on_died() -> void:
	super._on_died()
	_hit_anim_playing = false
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
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(idle_animation):
			sprite.play(idle_animation)
	if hurtbox:
		hurtbox.set_deferred("monitoring", true)
		hurtbox.set_deferred("monitorable", true)

func reset_stats() -> void:
	total_damage = 0
	last_damage = 0
	_hits.clear()
	dps = 0.0
