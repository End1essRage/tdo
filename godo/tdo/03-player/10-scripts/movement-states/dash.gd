extends State

@export var dash_duration: float = 0.2
var dash_timer: float = 0.0

func enter() -> void:
	dash_timer = dash_duration
	player.sprite.modulate = Color(0.5, 0.8, 1.0, 0.7)
	player.update_animation("run_")

func physics_update(delta: float) -> void:
	dash_timer -= delta
	player.velocity = player.facing_direction * player.dash_speed
	
	if dash_timer <= 0:
		if player.input_comp.direction != Vector2.ZERO:
			transitioned.emit("WalkState")
		else:
			transitioned.emit("IdleState")

func exit() -> void:
	player.sprite.modulate = Color(1, 1, 1, 1)
	# Устанавливаем кулдаун дэша в Player
	player.dash_cooldown = player.dash_cooldown_duration
