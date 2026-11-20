extends State

func enter() -> void:
	player.velocity = Vector2.ZERO
	player.update_animation("idle_")

func physics_update(_delta: float) -> void:
	# InputComponent сам вызовет transition_to("DashState") при нажатии кнопки
	# Нам остаётся только проверить движение
	
	var input = player.get_node_or_null("InputComponent")
	if input != null and input.direction != Vector2.ZERO:
		transitioned.emit("WalkState")
