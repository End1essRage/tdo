extends Node
class_name DamageFlashComponent

var player: Player
@export var flash_duration: float = 0.15
@export var flash_color: Color = Color.RED

func _ready() -> void:
	player = get_parent() as Player
	
	# Ищем health_component напрямую в дереве, а не через переменную player.health_component
	var hc = player.get_node_or_null("HealthComponent")
	
	if hc != null:
		hc.damage_taken.connect(_on_damage_taken)
		print("✅ DamageFlashComponent: Успешно подключился к HealthComponent")
	else:
		push_warning("⚠️ DamageFlashComponent: HealthComponent не найден в дереве игрока.")

func _on_damage_taken(_amount: int) -> void:
	var tween = player.sprite.create_tween()
	tween.tween_property(player.sprite, "self_modulate", flash_color, 0.0)
	tween.tween_property(player.sprite, "self_modulate", Color.WHITE, flash_duration)
