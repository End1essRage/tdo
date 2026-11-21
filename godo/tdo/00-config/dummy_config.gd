extends Resource
class_name DummyConfig

@export_group("Dummy")
@export var custom_sprite_frames: SpriteFrames
@export var idle_animation: StringName = &"default"
@export var on_hit_animation: StringName = &"take_damage_s"
@export var max_hp: int = 500
@export var max_shield: int = 0
@export var respawn_delay: float = 1.5
@export var body_size: Vector2 = Vector2(14, 14)
@export var hurtbox_size: Vector2 = Vector2(16, 22)
@export var track_dps: bool = true

@export_group("Collision")
@export_flags_2d_physics var body_layer: int = 4      # слой "enemies"
@export_flags_2d_physics var body_mask: int = 1
@export_flags_2d_physics var hurtbox_layer: int = 8   # слой "hurtboxes"
@export_flags_2d_physics var hurtbox_mask: int = 0

@export_group("UI")
@export var show_health_bar: bool = true
@export var show_damage_numbers: bool = true
