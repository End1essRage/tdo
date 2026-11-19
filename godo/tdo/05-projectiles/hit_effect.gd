extends AnimatedSprite2D

func setup_impact(frames: SpriteFrames, anim_name: String = "default", anim_speed: float = 15.0) -> void:
	if frames == null:
		queue_free()
		return

	# Дублируем ресурс, чтобы не менять оригинальный файл на диске/в памяти
	# (вдруг другие пули используют этот же SpriteFrames с другими настройками)
	var local_frames = frames.duplicate()
	
	# Проверяем, есть ли нужная анимация
	if not local_frames.has_animation(anim_name):
		var available = local_frames.get_animation_names()
		if not available.is_empty():
			anim_name = available[0]
		else:
			queue_free()
			return

	# Переопределяем настройки анимации
	local_frames.set_animation_loop(anim_name, false) # Отключаем цикл
	local_frames.set_animation_speed(anim_name, anim_speed) # Меняем скорость
	
	sprite_frames = local_frames
	animation_finished.connect(queue_free)
	
	# Запускаем
	play(anim_name)
