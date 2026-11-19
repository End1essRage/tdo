extends Node2D
class_name EnemyHealthBar

@export_group("Layout")
@export var bar_size: Vector2 = Vector2(20, 3)
@export var offset_y: float = -18.0
@export var shield_height: float = 2.0

@export_group("Behavior")
@export var hide_when_full: bool = true
@export var hide_delay: float = 2.0
@export var fill_speed: float = 20.0
@export var chip_delay: float = 0.25
@export var chip_speed: float = 5.0
@export var fade_speed: float = 10.0

@export_group("Colors")
@export var palette: UIPalette

var color_hp: Color = Color(0.85, 0.2, 0.25)
var color_chip: Color = Color(1, 0.85, 0.4)
var color_shield: Color = Color(0.45, 0.7, 1.0)
var color_bg: Color = Color(0, 0, 0, 0.55)

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

	_hp_ratio = float(health.hp) / max(1.0, float(health.max_hp))
	_shown_ratio = _hp_ratio
	_chip_ratio = _hp_ratio
	if health.max_shield > 0:
		_shield_ratio = float(health.shield) / float(health.max_shield)
	_update_visibility_target()
	modulate.a = _visible_target

func _apply_palette() -> void:
	if palette == null:
		return
	color_hp = palette.color_enemy_hp
	color_chip = palette.color_enemy_hp_chip
	color_shield = palette.color_enemy_shield
	color_bg = palette.color_enemy_bar_bg

func _build() -> void:
	var x := -bar_size.x * 0.5

	bg = ColorRect.new()
	bg.color = color_bg
	bg.size = bar_size + Vector2(2, 2)
	bg.position = Vector2(x - 1, offset_y - 1)
	add_child(bg)

	chip = ColorRect.new()
	chip.color = color_chip
	chip.size = bar_size
	chip.position = Vector2(x, offset_y)
	add_child(chip)

	fill = ColorRect.new()
	fill.color = color_hp
	fill.size = bar_size
	fill.position = Vector2(x, offset_y)
	add_child(fill)

	shield_bar = ColorRect.new()
	shield_bar.color = color_shield
	shield_bar.size = Vector2(0, shield_height)
	shield_bar.position = Vector2(x, offset_y - shield_height - 1)
	add_child(shield_bar)

func _on_hp_changed(current: int, maximum: int) -> void:
	_hp_ratio = float(current) / max(1.0, float(maximum))
	_chip_timer = chip_delay
	_hide_timer = hide_delay
	_update_visibility_target()

func _on_shield_changed(current: int, maximum: int) -> void:
	_shield_ratio = float(current) / max(1.0, float(maximum))
	_hide_timer = hide_delay
	_update_visibility_target()

func _update_visibility_target() -> void:
	if not hide_when_full:
		_visible_target = 1.0
		return
	_visible_target = 0.0 if _hp_ratio >= 0.999 and (_shield_ratio >= 0.999 or (health and health.max_shield == 0)) else 1.0

func _process(delta: float) -> void:
	if _hide_timer > 0.0:
		_hide_timer -= delta
	elif hide_when_full:
		_visible_target = 0.0

	_shown_ratio = lerp(_shown_ratio, _hp_ratio, clamp(fill_speed * delta, 0.0, 1.0))

	if _chip_timer > 0.0:
		_chip_timer -= delta
	else:
		_chip_ratio = lerp(_chip_ratio, _hp_ratio, clamp(chip_speed * delta, 0.0, 1.0))
	_chip_ratio = max(_chip_ratio, _shown_ratio)

	fill.size.x = bar_size.x * clamp(_shown_ratio, 0.0, 1.0)
	chip.size.x = bar_size.x * clamp(_chip_ratio, 0.0, 1.0)
	shield_bar.size.x = bar_size.x * clamp(_shield_ratio, 0.0, 1.0)
	shield_bar.visible = _shield_ratio > 0.001

	modulate.a = lerp(modulate.a, _visible_target, clamp(fade_speed * delta, 0.0, 1.0))
	visible = modulate.a > 0.01
