extends Node
class_name DamageFlashComponent

@export var flash_duration: float = 0.12
@export var flash_color: Color = Color(1, 1, 1, 1) # белый «выжженный» блик
@export var use_modulate: bool = true

var host: Node
var target: CanvasItem
var _tween: Tween

func _ready() -> void:
	host = get_parent()
	target = _find_visual()

	var hc = host.get_node_or_null("HealthComponent")
	if hc != null:
		hc.damage_taken.connect(_on_damage_taken)

func _find_visual() -> CanvasItem:
	# сначала по имени, потом любой CanvasItem-ребёнок
	var by_name = host.get_node_or_null("AnimatedSprite2D")
	if by_name == null:
		by_name = host.get_node_or_null("Sprite2D")
	if by_name is CanvasItem:
		return by_name
	for child in host.get_children():
		if child is CanvasItem:
			return child
	return null

func _on_damage_taken(_amount: int) -> void:
	if target == null:
		return
	if _tween and _tween.is_valid():
		_tween.kill()

	var prop := "modulate" if use_modulate else "self_modulate"
	target.set(prop, flash_color)
	_tween = create_tween()
	_tween.tween_property(target, prop, Color.WHITE, flash_duration)
