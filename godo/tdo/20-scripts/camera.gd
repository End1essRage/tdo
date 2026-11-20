extends Camera2D

@export var deadzone_size: Vector2 = Vector2(100, 80) # Окно (мертвая зона)
@export var smoothing_speed: float = 5.0 # Плавность
@export var zoom_level: float = 2.0 # Зум

var target: Node2D
var current_position: Vector2

func _ready() -> void:
	zoom = Vector2(zoom_level, zoom_level)
	
	# Ждем один кадр, чтобы PlayerBuilder успел создать игрока
	await get_tree().process_frame
	
	# Ищем игрока в группе "player"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		current_position = target.global_position
		global_position = current_position
	else:
		push_error("Камера: Игрок с группой 'player' не найден!")

func _process(delta: float) -> void:
	if not target:
		return
		
	var target_pos = target.global_position
	var diff = target_pos - current_position
	
	# Проверка мертвой зоны по X
	if abs(diff.x) > deadzone_size.x / 2.0:
		var target_x = target_pos.x - (sign(diff.x) * deadzone_size.x / 2.0)
		current_position.x = lerp(current_position.x, target_x, delta * smoothing_speed)
		
	# Проверка мертвой зоны по Y
	if abs(diff.y) > deadzone_size.y / 2.0:
		var target_y = target_pos.y - (sign(diff.y) * deadzone_size.y / 2.0)
		current_position.y = lerp(current_position.y, target_y, delta * smoothing_speed)
		
	global_position = current_position
