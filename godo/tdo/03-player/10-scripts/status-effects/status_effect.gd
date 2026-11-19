extends RefCounted
class_name StatusEffect

var effect_name: String
var duration: float

func _init(p_name: String, p_duration: float) -> void:
	effect_name = p_name
	duration = p_duration

func update(_delta: float) -> void:
	duration -= _delta

func on_apply(_player: Player) -> void:
	pass

func on_remove(_player: Player) -> void:
	pass
