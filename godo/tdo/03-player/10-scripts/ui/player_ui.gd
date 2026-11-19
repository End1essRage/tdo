extends Node2D
class_name PlayerUI

var player: Player
var hp_bar: ColorRect
var shield_bar: ColorRect
var ammo_bar: ColorRect
var reload_bar: ColorRect

# --- НАСТРОЙКИ РАЗМЕРОВ ---
@export_group("Layout")
@export var bar_width: float = 24.0
@export var bar_height: float = 3.0
@export var bar_spacing: float = 2.0
@export var offset_y: float = -28.0

# --- ПАЛИТРА ЦВЕТОВ ---
@export_group("Colors")
@export var color_hp: Color = Color.RED
@export var color_shield: Color = Color.CORNFLOWER_BLUE
@export var color_ammo: Color = Color.YELLOW
@export var color_reload: Color = Color.GREEN
@export var color_reload_perfect: Color = Color.GOLD

func _ready() -> void:
	player = get_parent() as Player
	_create_bars()
	_connect_signals_safely()

func _create_bars() -> void:
	hp_bar = _create_bar(color_hp, 0)
	shield_bar = _create_bar(color_shield, 1)
	ammo_bar = _create_bar(color_ammo, 2)
	reload_bar = _create_bar(color_reload, 3)
	reload_bar.size.x = 0.0

func _create_bar(color: Color, index: int) -> ColorRect:
	var bar = ColorRect.new()
	bar.color = color
	bar.size = Vector2(bar_width, bar_height)
	var y_pos = offset_y + (index * (bar_height + bar_spacing))
	bar.position = Vector2(-bar_width / 2.0, y_pos)
	add_child(bar)
	return bar

func _connect_signals_safely() -> void:
	var health_comp = player.get_node_or_null("HealthComponent")
	if health_comp:
		health_comp.hp_changed.connect(_on_hp_changed)
		health_comp.shield_changed.connect(_on_shield_changed)

	var shooting_comp = player.get_node_or_null("ShootingComponent")
	if shooting_comp:
		shooting_comp.ammo_changed.connect(_on_ammo_changed)

	var reload_comp = player.get_node_or_null("ReloadComponent")
	if reload_comp:
		reload_comp.reload_progress_changed.connect(_on_reload_progress_changed)

func _on_hp_changed(current: int, maximum: int) -> void:
	hp_bar.size.x = bar_width * (float(current) / maximum)

func _on_shield_changed(current: int, maximum: int) -> void:
	shield_bar.size.x = bar_width * (float(current) / maximum)

func _on_ammo_changed(current: int, maximum: int) -> void:
	ammo_bar.size.x = bar_width * (float(current) / maximum)

func _on_reload_progress_changed(progress: float) -> void:
	reload_bar.size.x = bar_width * progress
	var reload_comp = player.get_node_or_null("ReloadComponent")
	if reload_comp and reload_comp.current_phase == reload_comp.ReloadPhase.PERFECT_WINDOW:
		reload_bar.color = color_reload_perfect
	else:
		reload_bar.color = color_reload
