class_name InputComponent
extends Node2D

var direction: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.ZERO  # НОВОЕ: направление к курсору
var player: Player

func _ready() -> void:
	player = get_parent() as Player

func _process(_delta: float) -> void:
	# Движение
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	# Прицеливание — в сторону курсораget_global_mouse_position
	if player != null:
		var mouse_pos := get_global_mouse_position()
		aim_direction = (mouse_pos - player.global_position).normalized()
	
	# Дэш
	if Input.is_action_just_pressed("dash"):
		if player != null and player.use_dash_charge():
			player.movement_state_machine.transition_to("DashState")
	
	# Стрельба (зажатие)
	if Input.is_action_pressed("shoot"):
		if player != null and player.shooting_component != null:
			player.shooting_component.try_shoot(aim_direction)
	
	# Каст (одиночное нажатие)
	if Input.is_action_just_pressed("cast"):
		if player != null and player.cast_component != null:
			player.cast_component.try_cast(aim_direction)
	
	# Перезарядка
	if Input.is_action_just_pressed("reload"):
		if player != null and player.reload_component != null:
			var rc = player.reload_component
			if rc.current_phase == rc.ReloadPhase.IDLE:
				rc.start_reload()
			else:
				rc.try_manual_reload()
