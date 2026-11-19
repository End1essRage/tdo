extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var lifetime: float = 2.0
@export var damage: int = 10
@export var is_crit: bool = false
@export var pierce: int = 0

var direction: Vector2 = Vector2.RIGHT
var _hit_entities: Array[Node] = []
var _timer: float = 0.0

func _ready() -> void:
	rotation = direction.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	# Отложенная инициализация - дети будут готовы
	call_deferred("_init_visuals")

func _init_visuals() -> void:
	var aspr := get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
	if aspr == null:
		aspr = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if aspr == null:
		print("⚠️ Projectile: AnimatedSprite2D не найден. Дети: ", 
			get_children().map(func(c): return c.name))
		return
	if aspr == null:
		push_warning("Projectile: AnimatedSprite2D не найден в сцене пули")
		return
	if aspr.sprite_frames == null:
		push_warning("Projectile: SpriteFrames пустые!")
		return
	var names := aspr.sprite_frames.get_animation_names()
	if names.is_empty():
		push_warning("Projectile: нет анимаций в SpriteFrames")
		return
	var anim := "default" if "default" in names else names[0]
	aspr.play(anim)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()
		print("timed")

func _on_body_entered(body: Node) -> void:
	print("_on_body_entered")
	if body in _hit_entities:
		return
	if body.has_method("take_damage"):
		_apply_hit(body)

func _on_area_entered(area: Area2D) -> void:
	print("_on_area_entered")
	if area in _hit_entities:
		return
	if area.has_method("take_damage"):
		_apply_hit(area)

func _apply_hit(target: Node) -> void:
	_hit_entities.append
