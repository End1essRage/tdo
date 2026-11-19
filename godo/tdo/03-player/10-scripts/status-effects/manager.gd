extends Node
class_name StatusEffectManager

var player: Player
var active_effects: Dictionary = {} # {effect_name: StatusEffect}

func _ready() -> void:
	player = get_parent()

func _process(delta: float) -> void:
	# Обновляем все активные эффекты
	for effect_name in active_effects.keys():
		var effect = active_effects[effect_name]
		effect.update(delta)
		
		if effect.duration <= 0:
			remove_effect(effect_name)

func apply_effect(effect: StatusEffect) -> void:
	# Если эффект уже есть, обновляем длительность
	if active_effects.has(effect.effect_name):
		active_effects[effect.effect_name].duration = effect.duration
	else:
		active_effects[effect.effect_name] = effect
		effect.on_apply(player)

func remove_effect(effect_name: String) -> void:
	if active_effects.has(effect_name):
		active_effects[effect_name].on_remove(player)
		active_effects.erase(effect_name)

func has_effect(effect_name: String) -> bool:
	return active_effects.has(effect_name)
