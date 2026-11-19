extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var lifetime: float = 2.0
@export var damage: int = 10
@export var is_crit: bool = false
@export var pierce: int = 0  # Сколько целей пробивает

var direction: Vector2 = Vector2.RIGHT
var _hit_entities: Array[Node] = []  # Чтобы не бить одну цель дважды
var _timer: float = 0.0

func _ready() -> void:
	# Поворачиваем спрайт в направлении полёта
	rotation = direction.angle()
	# Коллизия
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_timer += delta
	if _timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if body in _hit_entities:
		return
	if body.has_method("take_damage"):
		_apply_hit(body)

func _on_area_entered(area: Area2D) -> void:
	if area in _hit_entities:
		return
	if area.has_method("take_damage"):
		_apply_hit(area)

func _apply_hit(target: Node) -> void:
	_hit_entities.append(target)
	var applied := target.take_damage(damage, is_crit) as int
	
	if pierce > 0:
		pierce -= 1
	else:
		_on_destroy()

func _on_destroy() -> void:
	# Тут можно добавить эффект взрыва/искры
	queue_free()
