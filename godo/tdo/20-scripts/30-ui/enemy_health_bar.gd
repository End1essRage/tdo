extends Node2D
class_name EnemyHealthBar

var cfg: EnemyHpBarConfig

var color_hp: Color = Color(0.85, 0.2, 0.25)
var color_chip: Color = Color(1, 0.85, 0.4)
var color_shield: Color = Color(0.45, 0.7, 1.0)
var color_bg: Color = Color(0, 0, 0, 0)

var health: Node
var bg: ColorRect
var chip: ColorRect
var fill: ColorRect
var shield_bar: ColorRect

var _hp_ratio: float = 1.0
var _shown_ratio: float = 1.0
var _chip_ratio: float = 1.0
var _shield_ratio: float = 0.0
var _chip_timer: float = 0.0
var _hide_timer: float = 0.0
var _visible_target: float = 1.0


func _ready() -> void:
	_apply_palette()
	_build()

	health = get_parent().get_node_or_null("HealthComponent")
	if health == null:
		push_warning("EnemyHealthBar: HealthComponent не найден у родителя.")
		return

	health.hp_changed.connect(_on_hp_changed)
	health.shield_changed.connect(_on_shield_changed)

	_hp_ratio = _ratio(health.hp, health.max_hp)
	_shown_ratio = _hp_ratio
	_chip_ratio = _hp_ratio
	if health.max_shield > 0:
		_shield_ratio = _ratio(health.shield, health.max_shield)
	_update_visibility_target()
	modulate.a = _visible_target


func _ratio(current: int, maximum: int) -> float:
	return float(current) / max(1.0, float(maximum))


func _apply_palette() -> void:
	if cfg.palette == null:
		return
	color_hp = cfg.palette.color_enemy_hp
	color_chip = cfg.palette.color_enemy_hp_chip
	color_shield = cfg.palette.color_enemy_shield
	color_bg = cfg.palette.color_enemy_bar_bg


func _build() -> void:
	var x := -cfg.bar_size.x * 0.5
	bg         = _make_rect(color_bg,     cfg.bar_size + Vector2(2, 2), Vector2(x - 1, cfg.offset_y - 1))
	chip       = _make_rect(color_chip,   cfg.bar_size,                 Vector2(x, cfg.offset_y))
	fill       = _make_rect(color_hp,     cfg.bar_size,                 Vector2(x, cfg.offset_y))
	shield_bar = _make_rect(color_shield, Vector2(0, cfg.shield_height), Vector2(x, cfg.offset_y - cfg.shield_height - 1))


func _make_rect(color: Color, size: Vector2, pos: Vector2) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.size = size
	rect.position = pos
	add_child(rect)
	return rect


func _on_hp_changed(current: int, maximum: int) -> void:
	_hp_ratio = _ratio(current, maximum)
	_chip_timer = cfg.chip_delay
	_hide_timer = cfg.hide_delay
	_update_visibility_target()


func _on_shield_changed(current: int, maximum: int) -> void:
	_shield_ratio = _ratio(current, maximum)
	_hide_timer = cfg.hide_delay
	_update_visibility_target()


func _update_visibility_target() -> void:
	if not cfg.hide_when_full:
		_visible_target = 1.0
		return
	var full_hp := _hp_ratio >= 0.999
	var full_shield: bool
	full_shield = _shield_ratio >= 0.999 or health.max_shield == 0
	_visible_target = 0.0 if full_hp and full_shield else 1.0


func _process(delta: float) -> void:
	if _hide_timer > 0.0:
		_hide_timer -= delta
	elif cfg.hide_when_full:
		_visible_target = 0.0

	_shown_ratio = lerp(_shown_ratio, _hp_ratio, clamp(cfg.fill_speed * delta, 0.0, 1.0))

	if _chip_timer > 0.0:
		_chip_timer -= delta
	else:
		_chip_ratio = lerp(_chip_ratio, _hp_ratio, clamp(cfg.chip_speed * delta, 0.0, 1.0))
	_chip_ratio = max(_chip_ratio, _shown_ratio)

	fill.size.x = cfg.bar_size.x * clamp(_shown_ratio, 0.0, 1.0)
	chip.size.x = cfg.bar_size.x * clamp(_chip_ratio, 0.0, 1.0)
	shield_bar.size.x = cfg.bar_size.x * clamp(_shield_ratio, 0.0, 1.0)
	shield_bar.visible = _shield_ratio > 0.001

	modulate.a = lerp(modulate.a, _visible_target, clamp(cfg.fade_speed * delta, 0.0, 1.0))
	visible = modulate.a > 0.01
