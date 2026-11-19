class_name MovementStateMachine
extends Node

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.player = get_parent() # <-- Явно берем родителя (Player)
			child.transitioned.connect(_on_child_transitioned)
	
	if states.has("idlestate"):
		current_state = states["idlestate"]
		current_state.enter()

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)
		
func transition_to(new_state_name: String) -> void:
	_on_child_transitioned(new_state_name)
	
func _on_child_transitioned(new_state_name: String) -> void:
	var new_state = states.get(new_state_name.to_lower())
	if not new_state or new_state == current_state:
		return
	
	current_state.exit()
	current_state = new_state
	current_state.enter()
