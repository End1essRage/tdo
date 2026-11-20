extends CharacterBody2D
class_name EnemyBase

signal died
signal damaged(amount: int, is_crit: bool)

var sprite: CanvasItem
var health_component: HealthComponent
var hurtbox: Hurtbox

func _ready() -> void:
	sprite = get_node_or_null("AnimatedSprite2D")
	if sprite == null:
		sprite = get_node_or_null("Sprite2D")
	health_component = get_node_or_null("HealthComponent")
	hurtbox = get_node_or_null("Hurtbox")

	if health_component:
		health_component.died.connect(_on_died)
		health_component.damage_received.connect(_on_damage_received)

	_configure()

# Переопределяется наследниками (манекен,.mob и т.д.)
func _configure() -> void:
	pass

func take_damage(amount: int, is_crit: bool = false) -> int:
	if health_component == null:
		return 0
	return health_component.take_damage(amount, is_crit)

func is_alive() -> bool:
	return health_component != null and not health_component.is_dead

func get_hit_position() -> Vector2:
	return global_position

func _on_damage_received(amount: int, is_crit: bool) -> void:
	damaged.emit(amount, is_crit)

func _on_died() -> void:
	died.emit()
