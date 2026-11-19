extends Node2D
class_name DashChargesUI

var player: Player

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
var color_ready_bg: Color = Color(0, 0.5, 0.5, 0.6)      # НОВОЕ
var color_cooldown_bg: Color = Color(0.1, 0.1, 0.1, 0.6)  # НОВОЕ

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
	player = get_parent() as Player
	if player == null:
		push_error("DashChargesUI: родитель не является Player!")
		return
	_apply_palette()
	_build_ui()

# --- ПРИМЕНЯЕМ ЦВЕТА ИЗ ПАЛИТРЫ ---
func _apply_palette() -> void:
	if palette:
		color_empty = palette.color_dash_empty
		color_full = palette.color_dash_full
		color_charging = palette.color_dash_charging
		color_no_charges_bg = palette.color_dash_no_charges_bg
		color_normal_bg = palette.color_dash_normal_bg
		color_ready_bg = palette.color_dash_ready_bg        # НОВОЕ
		color_cooldown_bg = palette.color_dash_cooldown_bg  # НОВОЕ

func _build_ui() -> void:
	background = ColorRect.new()
	background.color = color_normal_bg
	background.size = Vector2(
		player.max_dashes * charge_size.x + (player.max_dashes - 1) * charge_spacing + 4,
		charge_size.y + 4
	)
	background.position = Vector2(-background.size.x / 2.0, offset_y - 2)
	add_child(background)
	
	charges_container = HBoxContainer.new()
	charges_container.add_theme_constant_override("separation", int(charge_spacing))
	charges_container.position = Vector2(
		-(player.max_dashes * charge_size.x + (player.max_dashes - 1) * charge_spacing) / 2.0,
		offset_y
	)
	add_child(charges_container)
	
	charge_slots.clear()
	for i in range(player.max_dashes):
		var slot = _create_charge_slot()
		charges_container.add_child(slot.root)
		charge_slots.append(slot)

func _create_charge_slot() -> ChargeSlot:
	var root = Control.new()
	root.custom_minimum_size = charge_size
	root.size = charge_size
	root.clip_contents = true
	
	var bg = ColorRect.new()
	bg.color = color_empty
	bg.size = charge_size
	bg.position = Vector2.ZERO
	root.add_child(bg)
	
	var fill = ColorRect.new()
	fill.color = color_full
	fill.size = Vector2(0, charge_size.y)
	fill.position = Vector2.ZERO
	root.add_child(fill)
	
	return ChargeSlot.new(root, bg, fill)

func _process(_delta: float) -> void:
	if player == null:
		return
	_update_visuals()

func _update_visuals() -> void:
	# --- НОВОЕ: Логика цвета рамки ---
	if player.current_dashes == 0:
		# 0 зарядов — красный фон
		background.color = color_no_charges_bg
	elif player.dash_cooldown_timer > 0:
		# Есть заряды, но кулдаун — тёмный фон
		background.color = color_cooldown_bg
	else:
		# Есть заряды и нет кулдауна — яркий фон (можно дэш!)
		background.color = color_ready_bg
	
	# Перестроение UI, если max_dashes изменился
	if charge_slots.size() != player.max_dashes:
		for child in charges_container.get_children():
			child.queue_free()
		charge_slots.clear()
		for i in range(player.max_dashes):
			var slot = _create_charge_slot()
			charges_container.add_child(slot.root)
			charge_slots.append(slot)
		
		background.size.x = player.max_dashes * charge_size.x + (player.max_dashes - 1) * charge_spacing + 4
		background.position.x = -background.size.x / 2.0
		charges_container.position.x = -(player.max_dashes * charge_size.x + (player.max_dashes - 1) * charge_spacing) / 2.0
	
	# Обновление слотов
	var recharge_progress = 0.0
	if player.current_dashes < player.max_dashes and player.dash_recharge_time > 0:
		recharge_progress = player.recharge_timer / player.dash_recharge_time
	
	for i in range(player.max_dashes):
		var state: int
		if i < player.current_dashes:
			state = 2
		elif i == player.current_dashes:
			state = 1
		else:
			state = 0
		
		charge_slots[i].update(state, recharge_progress, color_full, color_charging, color_empty)
