extends Node2D
class_name CursorComponent

@export_group("Appearance")
@export var size: float = 10.0
@export var thickness: float = 2.0
@export var color: Color = Color.WHITE
@export var outline_color: Color = Color.BLACK
@export var outline_thickness: float = 1.0

@export_group("Behavior")
@export var snap_to_grid: bool = false
@export var grid_size: int = 1

var _mouse_pos: Vector2 = Vector2.ZERO
var mouse_filter: int

func _ready() -> void:
	# Скрываем системный курсор
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# Прицел поверх всего
	z_index = 1000
	# Не влияет на физику
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
	_mouse_pos = get_global_mouse_position()
	if snap_to_grid and grid_size > 0:
		_mouse_pos = (_mouse_pos / grid_size).floor() * grid_size
	global_position = _mouse_pos
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(-size / 2.0, -size / 2.0, size, size)
	
	# Внешний контур (чёрный)
	if outline_thickness > 0:
		var outer := rect.grow(outline_thickness)
		draw_rect(outer, outline_color, false, outline_thickness)
	
	# Внутренний квадрат (белый)
	draw_rect(rect, color, false, thickness)

func _exit_tree() -> void:
	# Возвращаем системный курсор при удалении
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
