extends Node
class_name DamageNumbersComponent

@export_group("Layout")
@export var spawn_offset: Vector2 = Vector2(0, -14)
@export var horizontal_spread: float = 6.0
@export var rise_height: float = 16.0
@export var lifetime: float = 0.6
@export var font_size: int = 8
@export var crit_font_size: int = 11
@export var outline_size: int = 2

@export_group("Colors")
@export var palette: UIPalette

var color_normal: Color = Color.WHITE
var color_crit: Color = Color(1, 0.75, 0.15)
var color_outline: Color = Color(0, 0, 0, 0.9)

var host: Node2D
var _layer: Node2D

func _ready() -> void:
	host = get_parent() as Node2D
	if palette:
		color_normal = palette.color_damage_normal
		color_crit = palette.color_damage_crit
		color_outline = palette.color_damage_outline

	var hc = host.get_node_or_null("HealthComponent")
	if hc != null:
		hc.damage_received.connect(_on_damage_received)

func _get_layer() -> Node2D:
	if is_instance_valid(_layer):
		return _layer
	var root := get_tree().current_scene
	if root == null:
		return null
	_layer = root.get_node_or_null("DamageNumberLayer") as Node2D
	if _layer == null:
		_layer = Node2D.new()
		_layer.name = "DamageNumberLayer"
		_layer.z_index = 100
		root.add_child(_layer)
	return _layer

func _on_damage_received(amount: int, is_crit: bool) -> void:
	spawn_number(amount, is_crit)

func spawn_number(amount: int, is_crit: bool = false, custom_color: Color = Color.TRANSPARENT) -> void:
	var layer := _get_layer()
	if layer == null or host == null or amount <= 0:
		return

	var label := Label.new()
	label.text = str(amount)
	label.add_theme_font_size_override("font_size", crit_font_size if is_crit else font_size)
	label.add_theme_color_override("font_color", custom_color if custom_color.a > 0.0 else (color_crit if is_crit else color_normal))
	label.add_theme_color_override("font_outline_color", color_outline)
	label.add_theme_constant_override("outline_size", outline_size)
	label.z_index = 100
	layer.add_child(label)
	label.reset_size()

	var start := host.global_position + spawn_offset
	start.x += randf_range(-horizontal_spread, horizontal_spread)
	label.position = start - Vector2(label.size.x * 0.5, 0.0)

	var drift := randf_range(-4.0, 4.0)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position",
		label.position + Vector2(drift, -rise_height), lifetime)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, lifetime * 0.6)\
		.set_delay(lifetime * 0.4)
	tween.chain().tween_callback(label.queue_free)
