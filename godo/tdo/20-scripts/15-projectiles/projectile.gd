extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var lifetime: float = 2.0
@export var damage: int = 10
@export var is_crit: bool = false
@export var pierce: int = 0

@export_group("Hit Effect")
@export var impact_frames_path: String = "res://10-assets/20-sprite-frames/17-hits/1.tres"
@export var impact_anim_name: String = "default"
@export var impact_anim_speed: float = 15.0

const HIT_EFFECT_SCRIPT = preload("res://20-scripts/15-projectiles/hit_effect.gd")

# Кэш настроенных SpriteFrames. Ключ: "путь_к_файлу_скорость"
static var _frames_cache: Dictionary = {}

var direction: Vector2 = Vector2.RIGHT
var _hit_entities: Array[Node] = []
var _timer: float = 0.0

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body in _hit_entities: return
	if body.has_method("take_damage"): _apply_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area in _hit_entities: return
	if area.has_method("take_damage"): _apply_hit(area)

func _apply_hit(target: Node) -> void:
	if target in _hit_entities: return
	_hit_entities.append(target)

	if target.has_method("take_damage"):
		target.take_damage(damage, is_crit)

	_spawn_hit_effect(target)

	if pierce <= 0:
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
		queue_free()
	else:
		pierce -= 1

func _spawn_hit_effect(target: Node) -> void:
	if impact_frames_path == "":
		return

	# Формируем уникальный ключ для кэша (путь + скорость)
	var cache_key = impact_frames_path + "_" + str(impact_anim_speed)
	
	var frames: SpriteFrames = _frames_cache.get(cache_key)
	if frames == null:
		# Загружаем оригинал
		if not ResourceLoader.exists(impact_frames_path):
			push_error("Файл эффекта не найден: " + impact_frames_path)
			return
			
		var original = load(impact_frames_path) as SpriteFrames
		if original == null:
			push_error("Указанный файл не является SpriteFrames: " + impact_frames_path)
			return
			
		# Дублируем ОДИН раз и настраиваем
		frames = original.duplicate()
		
		# Проверяем и настраиваем анимацию
		if frames.has_animation(impact_anim_name):
			frames.set_animation_loop(impact_anim_name, false)
			frames.set_animation_speed(impact_anim_name, impact_anim_speed)
		else:
			var available = frames.get_animation_names()
			if not available.is_empty():
				frames.set_animation_loop(available[0], false)
				frames.set_animation_speed(available[0], impact_anim_speed)
				# Запоминаем, что нужно играть первую доступную
				# (это можно обработать в hit_effect.gd, но проще передать правильное имя)
				# Но так как мы передаем anim_name дальше, лучше не менять его, 
				# а в hit_effect.gd сделать fallback.
		
		# Сохраняем в кэш
		_frames_cache[cache_key] = frames

	# Создаем узел
	var effect := AnimatedSprite2D.new()
	effect.set_script(HIT_EFFECT_SCRIPT)
	effect.z_index = 100
	effect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var attach_to: Node2D = null
	if target is Hurtbox and is_instance_valid(target.entity) and target.entity is Node2D:
		attach_to = target.entity
	elif target is Node2D:
		attach_to = target
		
	if attach_to:
		attach_to.add_child(effect)
		effect.global_position = global_position
		effect.rotation = 0
	else:
		get_tree().current_scene.add_child(effect)
		effect.global_position = global_position

	# Передаем УЖЕ настроенный кэшированный frames
	effect.setup_impact(frames, impact_anim_name, impact_anim_speed)
