extends State

var dash_duration: float
var dash_timer: float
var dash_direction: Vector2 = Vector2.ZERO  # Фиксированное направление дэша

func enter() -> void:
	dash_timer = dash_duration
	
	# --- КЛЮЧЕВОЕ: Запоминаем направление в момент начала дэша ---
	# Если игрок нажал направление — летим туда
	if player.input_comp.direction != Vector2.ZERO:
		dash_direction = player.input_comp.direction.normalized()
	else:
		# Если не нажал — летим туда, куда смотрели
		dash_direction = player.facing_direction
	
	# Обновляем facing_direction, чтобы анимация соответствовала
	player.facing_direction = dash_direction
	
	player.sprite.modulate = Color(0.5, 0.8, 1.0, 0.7)
	player.update_animation("run_")

func physics_update(delta: float) -> void:
	dash_timer -= delta
	
	# --- КЛЮЧЕВОЕ: Летим строго в dash_direction, игнорируя инпут ---
	player.velocity = dash_direction * player.dash_component.dash_speed
	
	if dash_timer <= 0:
		if player.input_comp.direction != Vector2.ZERO:
			transitioned.emit("WalkState")
		else:
			transitioned.emit("IdleState")

func exit() -> void:
	player.sprite.modulate = Color(1, 1, 1, 1)
	player.dash_component.start_cooldown()
