class_name InputComponent
extends Node

var direction: Vector2 = Vector2.ZERO
var player: Player

func _ready() -> void:
	player = get_parent() as Player

func _process(_delta: float) -> void:
	# 1. Движение
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	# 2. Дэш — с защитой от траты заряда во время дэша
	if Input.is_action_just_pressed("dash"):
		if player != null and player.can_dash():
			player.use_dash_charge()
			player.movement_state_machine.transition_to("DashState")

	# 3. Стрельба
	if Input.is_action_pressed("shoot"):
		if player != null and player.shooting_component != null:
			player.shooting_component.try_shoot()
	
	# 4. Перезарядка
	if Input.is_action_just_pressed("reload"):
		if player != null and player.reload_component != null:
			if player.reload_component.current_phase == player.reload_component.ReloadPhase.IDLE:
				player.reload_component.start_reload()
			else:
				player.reload_component.try_manual_reload()
