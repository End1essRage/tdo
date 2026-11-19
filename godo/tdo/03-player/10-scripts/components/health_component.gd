extends Node
class_name HealthComponent

var player: Player
var shooting_comp: Node # Локальная ссылка

@export var max_hp: int = 100
@export var max_shield: int = 50
var hp: int
var shield: int
var regen_timer: float = 0.0
@export var shield_regen_delay: float = 3.0
@export var shield_regen_rate: float = 20.0

signal hp_changed(current: int, maximum: int)
signal shield_changed(current: int, maximum: int)
signal damage_taken(amount: int)

func _ready() -> void:
	player = get_parent() as Player
	if player == null:
		push_error("HealthComponent: Родитель не является узлом Player!")
		return

	hp = max_hp
	shield = max_shield
	
	# НАДЕЖНЫЙ ПОИСК: Ищем узел по имени напрямую. 
	# Он УЖЕ существует в дереве, даже если переменная player.shooting_component еще null.
	shooting_comp = player.get_node_or_null("ShootingComponent")
	
	if shooting_comp != null:
		# Подключаем сигнал. Все безопасно.
		shooting_comp.shot_fired.connect(_on_action_performed)
		print("✅ HealthComponent: Успешно нашел и подключился к ShootingComponent")
	else:
		push_warning("⚠️ HealthComponent: Узел 'ShootingComponent' не найден в дереве игрока.")

func _process(delta: float) -> void:
	if regen_timer > 0:
		regen_timer -= delta
	else:
		if shield < max_shield:
			shield = min(shield + shield_regen_rate * delta, max_shield)
			shield_changed.emit(shield, max_shield)

func take_damage(amount: int) -> void:
	if shield > 0:
		shield = max(0, shield - amount)
		shield_changed.emit(shield, max_shield)
	else:
		hp = max(0, hp - amount)
		hp_changed.emit(hp, max_hp)
	
	damage_taken.emit(amount)
	_on_action_performed()

func _on_action_performed() -> void:
	regen_timer = shield_regen_delay
