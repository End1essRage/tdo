extends Resource
class_name EnemyHpBarConfig

@export_group("Layout")
@export var bar_size: Vector2 = Vector2(20, 3)
@export var offset_y: float = -18.0
@export var shield_height: float = 2.0

@export_group("Behavior")
@export var hide_when_full: bool = true
@export var hide_delay: float = 2.0
@export var fill_speed: float = 20.0
@export var chip_delay: float = 0.25
@export var chip_speed: float = 5.0
@export var fade_speed: float = 10.0

@export_group("Colors")
@export var palette: UIPalette
