class_name InputComponent
extends Node

var direction: Vector2 = Vector2.ZERO
var player: Player # Ссылка на родителя

func _ready() -> void:
	player = get_parent()

func _process(_delta: float) -> void:
	# 1. Движение
	direction = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	).normalized()
	
	# 2. Дэш (проверяем кулдаун прямо в Player)
	if Input.is_action_just_pressed("dash"):
		if player.dash_cooldown <= 0:
			player.movement_state_machine.transition_to("DashState")
			# Кулдаун установится в DashState при exit()
		else:
			pass # Можно добавить звук "кулдаун еще идет"
	
	# 3. Стрельба (делегируем компоненту)
	if Input.is_action_pressed("shoot"):
		if player.shooting_component != null:
			player.shooting_component.try_shoot()
	
	# 4. Перезарядка
	if Input.is_action_just_pressed("reload"):
		if player.reload_component != null:
			if player.reload_component.current_phase == player.reload_component.ReloadPhase.IDLE:
				player.reload_component.start_reload()
			else:
				player.reload_component.try_manual_reload()
