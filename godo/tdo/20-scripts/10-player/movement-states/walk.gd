extends State

func enter() -> void:
	pass

func physics_update(delta: float) -> void:
	var dir = player.input_comp.direction
	if dir == Vector2.ZERO:
		transitioned.emit("IdleState")
		return
	
	player.facing_direction = dir
	
	# Используем новый метод для расчета скорости
	var current_speed = player.get_effective_speed(player.walk_speed)
	
	player.velocity = dir * current_speed
	player.move_and_slide()
	
	var anim_prefix = "walk_"
	
	player.update_animation(anim_prefix)
func exit() -> void:
	pass
