extends Node2D
class_name PlayerHUD

const PLAYER_UI_SCRIPT       = preload("res://20-scripts/30-ui/10-player-hud/player_ui.gd")
const DASH_CHARGES_UI_SCRIPT = preload("res://20-scripts/30-ui/dash_charges_ui.gd")

@export var palette: UIPalette

func _ready() -> void:
	_spawn(PLAYER_UI_SCRIPT,       "PlayerUI",       palette)
	_spawn(DASH_CHARGES_UI_SCRIPT, "DashChargesUI",  palette)

func _spawn(script: Script, node_name: String, pal: UIPalette) -> Node2D:
	var ui := Node2D.new()
	ui.name = node_name
	ui.set_script(script)
	if pal:
		ui.palette = pal
	add_child(ui)
	return ui
