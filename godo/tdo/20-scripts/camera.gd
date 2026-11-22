extends Camera2D

@export var deadzone_size: Vector2 = Vector2(100, 80)
@export var soft_zone: Vector2 = Vector2(80, 60)   # зона плавного нарастания
@export var smoothing_speed: float = 6.0
@export var max_speed: float = 1200.0              # макс. скорость камеры (px/s)
@export var zoom_level: float = 2.0

var target: Node2D
var current_position: Vector2

func _ready() -> void:
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	
	zoom = Vector2(zoom_level, zoom_level)
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		current_position = target.global_position
		global_position = current_position
	else:
		push_error("Камера: Игрок с группой 'player' не найден!")

func _physics_process(delta: float) -> void:
	if not target:
		return

	var diff = target.global_position - current_position

	# По каждой оси отдельно — плавное нарастание скорости
	current_position.x = _axis_step(current_position.x, diff.x, deadzone_size.x * 0.5, soft_zone.x, delta)
	current_position.y = _axis_step(current_position.y, diff.y, deadzone_size.y * 0.5, soft_zone.y, delta)

	global_position = current_position

func _axis_step(current: float, diff: float, dead_half: float, soft: float, delta: float) -> float:
	var d = abs(diff)
	if d <= dead_half:
		return current   # внутри мёртвой зоны — стоим

	# Насколько игрок вышел за мёртвую зону (0..1) — нормируем по soft
	var overshoot = (d - dead_half) / max(soft, 0.001)
	var t = clamp(overshoot, 0.0, 1.0)      # 0 на границе, 1 за soft-зоной
	# Плавное нарастание (ease-out), можно заменить на t*t или smoothstep
	var speed_factor = t * t * (3.0 - 2.0 * t)  # smoothstep

	# Желаемая скорость камеры
	var speed = lerp(0.0, max_speed, speed_factor)
	# Но не быстрее, чем нужно, чтобы догнать игрока
	var needed = lerp(0.0, d - dead_half, smoothing_speed * delta)  # плавное стремление
	var move = min(speed * delta, needed)

	return current + sign(diff) * move
