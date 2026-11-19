extends State

func enter() -> void:
	player.update_animation("run_")

func physics_update(_delta: float) -> void:
	if player.input_comp.is_dashing:
		transitioned.emit("DashState")
		return

	if player.input_comp.is_attacking and player.allow_attack_while_running:
		transitioned.emit("AttackState")
		return
		
	if player.input_comp.direction == Vector2.ZERO:
		transitioned.emit("IdleState")
	elif not player.input_comp.is_running:
		transitioned.emit("WalkState")
	else:
		player.velocity = player.input_comp.direction * player.run_speed
		player.update_animation("run_")
