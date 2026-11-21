extends Node2D
class_name DashChargesUI

var player: Player
var dash: DashComponent

# --- НАСТРОЙКИ РАЗМЕРОВ ---
@export_group("Layout")
@export var charge_size: Vector2 = Vector2(6, 6)
@export var charge_spacing: float = 2.0
@export var offset_y: float = -38.0

# --- ПАЛИТРА ---
@export_group("Colors")
@export var palette: UIPalette

# --- FALLBACK ЦВЕТА ---
var color_empty: Color = Color(0.2, 0.2, 0.2)
var color_full: Color = Color.CYAN
var color_charging: Color = Color(0.3, 0.7, 0.9)
var color_no_charges_bg: Color = Color(0.5, 0.1, 0.1, 0.6)
var color_normal_bg: Color = Color(0, 0, 0, 0.3)
var color_ready_bg: Color = Color(0, 0.5, 0.5, 0.6)
var color_cooldown_bg: Color = Color(0.1, 0.1, 0.1, 0.6)

# --- ВНУТРЕННИЕ УЗЛЫ ---
var charges_container: HBoxContainer
var background: ColorRect
var charge_slots: Array[ChargeSlot] = []

class ChargeSlot:
	var root: Control
	var bg: ColorRect
	var fill: ColorRect

	func _init(p_root: Control, p_bg: ColorRect, p_fill: ColorRect) -> void:
		root = p_root
		bg = p_bg
		fill = p_fill

	func update(state: int, progress: float, full_color: Color, charging_color: Color, empty_color: Color) -> void:
		match state:
			0:
				fill.size.x = 0.0
				bg.color = empty_color
			1:
				fill.size.x = bg.size.x * clamp(progress, 0.0, 1.0)
				fill.color = charging_color
			2:
				fill.size.x = bg.size.x
				fill.color = full_color

func _ready() -> void:
	# Родитель — PlayerHUD, его родитель — Player
	player = get_parent().get_parent() as Player
	if player == null:
		push_error("DashChargesUI: родитель не является Player!")
		return

	dash = player.get_node_or_null("DashComponent") as DashComponent
	if dash == null:
		push_error("DashChargesUI: DashComponent не найден")
		return

	dash.charges_changed.connect(_on_charges_changed)
	dash.cooldown_started.connect(_on_cooldown_changed)
	dash.cooldown_finished.connect(_on_cooldown_changed)

	_apply_palette()
	_build_ui()

# --- ПАЛИТРА ---
func _apply_palette() -> void:
	if palette:
		color_empty = palette.color_dash_empty
		color_full = palette.color_dash_full
		color_charging = palette.color_dash_charging
		color_no_charges_bg = palette.color_dash_no_charges_bg
		color_normal_bg = palette.color_dash_normal_bg
		color_ready_bg = palette.color_dash_ready_bg
		color_cooldown_bg = palette.color_dash_cooldown_bg

# --- СБОРКА UI ---
func _build_ui() -> void:
	background = ColorRect.new()
	background.color = color_normal_bg
	_recalc_layout()
	add_child(background)

	charges_container = HBoxContainer.new()
	charges_container.add_theme_constant_override("separation", int(charge_spacing))
	_recalc_layout()
	add_child(charges_container)

	_rebuild_slots()

func _recalc_layout() -> void:
	if dash == null:
		return
	var total_width := dash.max_dashes * charge_size.x \
		+ (dash.max_dashes - 1) * charge_spacing

	if background:
		background.size = Vector2(total_width + 4, charge_size.y + 4)
		background.position = Vector2(-background.size.x / 2.0, offset_y - 2)

	if charges_container:
		charges_container.position = Vector2(-total_width / 2.0, offset_y)

func _rebuild_slots() -> void:
	for child in charges_container.get_children():
		child.queue_free()
	charge_slots.clear()
	for i in range(dash.max_dashes):
		var slot := _create_charge_slot()
		charges_container.add_child(slot.root)
		charge_slots.append(slot)

func _create_charge_slot() -> ChargeSlot:
	var root := Control.new()
	root.custom_minimum_size = charge_size
	root.size = charge_size
	root.clip_contents = true

	var bg := ColorRect.new()
	bg.color = color_empty
	bg.size = charge_size
	bg.position = Vector2.ZERO
	root.add_child(bg)

	var fill := ColorRect.new()
	fill.color = color_full
	fill.size = Vector2(0, charge_size.y)
	fill.position = Vector2.ZERO
	root.add_child(fill)

	return ChargeSlot.new(root, bg, fill)

# --- РЕАКЦИЯ НА СИГНАЛЫ ---
func _on_charges_changed(_current: int, _maximum: int) -> void:
	_update_visuals()

func _on_cooldown_changed(_arg = null) -> void:
	_update_visuals()

# --- ОБНОВЛЕНИЕ ВИЗУАЛА ---
func _process(_delta: float) -> void:
	if dash == null:
		return
	# Перестроение, если max_dashes изменился (например, из баффа)
	if charge_slots.size() != dash.max_dashes:
		_recalc_layout()
		_rebuild_slots()
	_update_visuals()

func _update_visuals() -> void:
	# Цвет фона
	if dash.current_dashes == 0:
		background.color = color_no_charges_bg
	elif dash.is_on_cooldown():
		background.color = color_cooldown_bg
	else:
		background.color = color_ready_bg

	var progress := dash.get_recharge_progress()

	for i in range(dash.max_dashes):
		var state: int
		if i < dash.current_dashes:
			state = 2
		elif i == dash.current_dashes:
			state = 1
		else:
			state = 0
		charge_slots[i].update(state, progress, color_full, color_charging, color_empty)
