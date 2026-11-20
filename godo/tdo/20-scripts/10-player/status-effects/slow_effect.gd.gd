extends StatusEffect
class_name SlowEffect

var slowdown_multiplier: float

func _init(p_duration: float, p_multiplier: float) -> void:
	super._init("slow", p_duration)
	slowdown_multiplier = p_multiplier

func on_apply(player: Player) -> void:
	player.status_effect_manager.apply_movement_multiplier(slowdown_multiplier)

func on_remove(player: Player) -> void:
	player.status_effect_manager.remove_movement_multiplier()
