extends Resource
class_name UIPalette

@export_group("Player Bars")
@export var color_hp: Color = Color.RED
@export var color_shield: Color = Color.CORNFLOWER_BLUE
@export var color_ammo: Color = Color.YELLOW
@export var color_reload: Color = Color.GREEN
@export var color_reload_perfect: Color = Color.GOLD

@export_group("Dash Charges")
@export var color_dash_empty: Color = Color(0.2, 0.2, 0.2)
@export var color_dash_full: Color = Color.CYAN
@export var color_dash_charging: Color = Color(0.3, 0.7, 0.9)
@export var color_dash_no_charges_bg: Color = Color(0.5, 0.1, 0.1, 0.6)
@export var color_dash_normal_bg: Color = Color(0, 0, 0, 0.3)
@export var color_dash_ready_bg: Color = Color(0, 0.5, 0.5, 0.6)
@export var color_dash_cooldown_bg: Color = Color(0.1, 0.1, 0.1, 0.6)

@export_group("Enemy Bars")
@export var color_enemy_hp: Color = Color(0.85, 0.2, 0.25)
@export var color_enemy_hp_chip: Color = Color(1, 0.85, 0.4)   # «догоняющий» урон
@export var color_enemy_shield: Color = Color(0.45, 0.7, 1.0)
@export var color_enemy_bar_bg: Color = Color(0, 0, 0, 0.55)

@export_group("Damage Numbers")
@export var color_damage_normal: Color = Color(1, 1, 1)
@export var color_damage_crit: Color = Color(1, 0.75, 0.15)
@export var color_damage_outline: Color = Color(0, 0, 0, 0.9)
