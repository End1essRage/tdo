extends AnimatedSprite2D

func setup_impact(frames: SpriteFrames, anim_name: String = "default", anim_speed: float = 15.0) -> void:
	if frames == null:
		queue_free()
		return

	# frames УЖЕ настроен (loop = false, скорость) в Projectile._spawn_hit_effect()
	sprite_frames = frames
	
	# Проверяем, есть ли нужная анимация
	if not sprite_frames.has_animation(anim_name):
		var available = sprite_frames.get_animation_names()
		if not available.is_empty():
			anim_name = available[0]
		else:
			queue_free()
			return

	# Подключаем сигнал окончания анимации
	animation_finished.connect(queue_free)
	
	# Запускаем
	play(anim_name)
