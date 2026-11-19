extends Node2D
class_name PlayerUI

var player: Player
var hp_bar: ColorRect
var shield_bar: ColorRect
var ammo_bar: ColorRect
var reload_bar: ColorRect

var health_component: Node
var shooting_component: Node
var reload_component: Node

@export var bar_width: float = 24.0
@export var bar_height: float = 3.0
@export var bar_spacing: float = 1.0
@export var offset_y: float = -20.0 # Над головой (спрайт 16px, берем с запасом)

func _ready() -> void:
	player = get_parent() as Player
	if player == null:
		push_error("HealthComponent: Родитель не является узлом Player!")
		return
	health_component = player.get_node_or_null("HealthComponent")
	shooting_component = player.get_node_or_null("ShootingComponent")
	reload_component = player.get_node_or_null("ReloadComponent")
	_create_bars()
	_connect_signals()

func _create_bars() -> void:
	# HP (красная)
	hp_bar = ColorRect.new()
	hp_bar.color = Color.RED
	hp_bar.size = Vector2(bar_width, bar_height)
	hp_bar.position = Vector2(-bar_width / 2, offset_y)
	add_child(hp_bar)
	
	# Щит (синий)
	shield_bar = ColorRect.new()
	shield_bar.color = Color.CORNFLOWER_BLUE
	shield_bar.size = Vector2(bar_width, bar_height)
	shield_bar.position = Vector2(-bar_width / 2, offset_y + bar_height + bar_spacing)
	add_child(shield_bar)
	
	# Патроны (желтая)
	ammo_bar = ColorRect.new()
	ammo_bar.color = Color.YELLOW
	ammo_bar.size = Vector2(bar_width, bar_height)
	ammo_bar.position = Vector2(-bar_width / 2, offset_y + (bar_height + bar_spacing) * 2)
	add_child(ammo_bar)
	
	# Перезарядка (зеленая, показывает прогресс)
	reload_bar = ColorRect.new()
	reload_bar.color = Color.GREEN
	reload_bar.size = Vector2(0, bar_height) # Начинается с 0
	reload_bar.position = Vector2(-bar_width / 2, offset_y + (bar_height + bar_spacing) * 3)
	add_child(reload_bar)

func _connect_signals() -> void:
	health_component.hp_changed.connect(_on_hp_changed)
	health_component.shield_changed.connect(_on_shield_changed)
	shooting_component.ammo_changed.connect(_on_ammo_changed)
	reload_component.reload_progress_changed.connect(_on_reload_progress_changed)

func _on_hp_changed(current: int, maximum: int) -> void:
	var ratio = float(current) / maximum
	hp_bar.size.x = bar_width * ratio

func _on_shield_changed(current: int, maximum: int) -> void:
	var ratio = float(current) / maximum
	shield_bar.size.x = bar_width * ratio

func _on_ammo_changed(current: int, maximum: int) -> void:
	var ratio = float(current) / maximum
	ammo_bar.size.x = bar_width * ratio

func _on_reload_progress_changed(progress: float) -> void:
	reload_bar.size.x = bar_width * progress
	# Меняем цвет в "идеальном окне"
	if player.reload_component.current_phase == player.reload_component.ReloadPhase.PERFECT_WINDOW:
		reload_bar.color = Color.GOLD
	else:
		reload_bar.color = Color.GREEN
