extends Area2D
class_name Hurtbox

var entity: Node

func take_damage(amount: int, is_crit: bool = false) -> int:
	if entity != null and entity.has_method("take_damage"):
		return entity.take_damage(amount, is_crit)
	return 0

func get_entity() -> Node:
	return entity
