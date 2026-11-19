extends Resource
class_name UIPalette

@export var color_hp: Color = Color.RED
@export var color_shield: Color = Color.CORNFLOWER_BLUE
@export var color_ammo: Color = Color.YELLOW
@export var color_reload: Color = Color.GREEN
@export var color_reload_perfect: Color = Color.GOLD

@export var color_dash_empty: Color = Color(0.2, 0.2, 0.2)
@export var color_dash_full: Color = Color.CYAN
@export var color_dash_charging: Color = Color(0.3, 0.7, 0.9)
@export var color_dash_no_charges_bg: Color = Color(0.5, 0.1, 0.1, 0.6)  # Красный, когда 0 зарядов
@export var color_dash_normal_bg: Color = Color(0, 0, 0, 0.3)

# --- НОВОЕ: Состояния готовности дэша ---
@export var color_dash_ready_bg: Color = Color(0, 0.5, 0.5, 0.6)  # Яркий, когда можно дэш
@export var color_dash_cooldown_bg: Color = Color(0.1, 0.1, 0.1, 0.6)  # Тёмный, когда кулдаун
