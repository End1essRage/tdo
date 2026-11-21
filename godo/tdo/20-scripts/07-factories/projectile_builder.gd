extends Node
class_name ProjectileBuilder

const PROJECTILE_SCRIPT = preload("res://20-scripts/15-projectiles/projectile.gd")

# Текущая сцена пули (может меняться в рантайме)
var current_bullet_scene: PackedScene = null

# Запасная сцена, если ничего не задано (жёлтый пиксель)
var _default_scene: PackedScene = null

func _ready() -> void:
	_default_scene = _build_default_scene()

# --- ПУБЛИЧНЫЕ МЕТОДЫ ---

# Задать сцену пули (вызывается из PlayerBuilder или в рантайме)
func set_bullet_scene(scene: PackedScene) -> void:
	if scene != null:
		current_bullet_scene = scene
	else:
		current_bullet_scene = _default_scene

# Спавн пули текущей сценой
func spawn_bullet(from: Vector2, dir: Vector2, p_cfg:ProjectileConfig, effect_path: String = "") -> Projectile:
	var p := current_bullet_scene.instantiate() as Projectile
	p.cfg = p_cfg
	p.direction = dir.normalized()
	
	# Если передан путь к эффекту, задаем его
	if effect_path != "":
		p.impact_frames_path = effect_path
		
	return p

# --- ВНУТРЕННЕЕ: дефолтная сцена (жёлтый пиксель 4x4) ---
func _build_default_scene() -> PackedScene:
	var root := Area2D.new()
	root.name = "Projectile"
	root.set_script(PROJECTILE_SCRIPT)
	root.collision_layer = 2
	root.collision_mask = 8

	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color.YELLOW)
	sprite.texture = ImageTexture.create_from_image(img)
	root.add_child(sprite)
	sprite.owner = root  # ← Ключевая строка

	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 3.0
	col.shape = shape
	root.add_child(col)
	col.owner = root  # ← Ключевая строка

	var scene := PackedScene.new()
	scene.pack(root)
	return scene
