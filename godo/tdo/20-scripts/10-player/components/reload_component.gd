extends Node
class_name ReloadComponent

enum ReloadPhase { IDLE, RELOADING, PERFECT_WINDOW }
var current_phase: ReloadPhase = ReloadPhase.IDLE
var reload_progress: float = 0.0
@export var reload_time: float = 2.0
@export var perfect_window_start: float = 0.9

signal reload_finished(is_perfect: bool)
signal reload_progress_changed(progress: float)

func _process(delta: float) -> void:
	if current_phase == ReloadPhase.IDLE:
		return
	
	reload_progress += delta / reload_time
	reload_progress_changed.emit(reload_progress)
	
	if reload_progress >= 1.0:
		finish_reload(false)
	elif reload_progress >= perfect_window_start and current_phase == ReloadPhase.RELOADING:
		current_phase = ReloadPhase.PERFECT_WINDOW

func start_reload() -> void:
	current_phase = ReloadPhase.RELOADING
	reload_progress = 0.0

func try_manual_reload() -> void:
	if current_phase == ReloadPhase.PERFECT_WINDOW:
		finish_reload(true)
	else:
		finish_reload(false)

func finish_reload(is_perfect: bool) -> void:
	current_phase = ReloadPhase.IDLE
	reload_progress = 0.0
	reload_progress_changed.emit(0.0)
	reload_finished.emit(is_perfect)
	
	if is_perfect:
		get_parent().shooting_component.reload_ammo() # Тут можно добавить бонус к урону
