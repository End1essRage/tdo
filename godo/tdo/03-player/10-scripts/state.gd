class_name State
extends Node

signal transitioned(new_state_name: String)

var player: Player # Ссылка на игрока

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
