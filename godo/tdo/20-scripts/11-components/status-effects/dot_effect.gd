extends StatusEffect
class_name DotEffect

var damage_per_second: float
var tick_timer: float = 0.0
var player: Player

func _init(p_duration: float, p_dps: float) -> void:
	super._init("dot", p_duration)
	damage_per_second = p_dps
	
func on_apply(_player: Player) -> void:
	player = _player
	
func update(delta: float) -> void:
	super.update(delta)
	tick_timer += delta
	
	if tick_timer >= 1.0: # Урон раз в секунду
		tick_timer = 0.0
		player.health_component.take_damage(damage_per_second)
