extends Node
class_name ProjectileBuilder

const PROJECTILE_SCRIPT = preload("res://05-projectiles/projectile.gd")

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
func spawn_bullet(from: Vector2, dir: Vector2, damage: int = 10, speed: float = 400.0, lifetime: float = 2.0) -> Projectile:
	if current_bullet_scene == null:
		push_error("ProjectileBuilder: сцена пули не задана!")
		return null
		
	print("📦 current_bullet_scene = ", current_bullet_scene.resource_path)
	var p := current_bullet_scene.instantiate() as Projectile
	print("📦 Инстанс: ", p, " | детей: ", p.get_children().size())
	for c in p.get_children():
		print("    - ", c.name, " (", c.get_class(), ")")
		
	#p.global_position = from
	p.direction = dir.normalized()
	p.damage = damage
	p.speed = speed
	p.lifetime = lifetime
	
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
