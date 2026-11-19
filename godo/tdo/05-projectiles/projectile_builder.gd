extends Node
class_name ProjectileBuilder

# Предустановки для разных типов снарядов
enum ProjectileType { BULLET, FIREBALL, ICE_SHARD }

# Сцена снаряда (создаётся один раз, инстансится много раз)
static var _bullet_scene: PackedScene
static var _fireball_scene: PackedScene

const PROJECTILE_SCRIPT = preload("res://05-projectiles/projectile.gd")

static func _ensure_scenes() -> void:
	if _bullet_scene == null:
		_bullet_scene = _build_bullet_scene()
	if _fireball_scene == null:
		_fireball_scene = _build_fireball_scene()

static func _build_bullet_scene() -> PackedScene:
	var root := Area2D.new()
	root.name = "Projectile"
	root.set_script(PROJECTILE_SCRIPT)
	
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	# Временная текстура — белый пиксель 4x4
	var img := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	img.fill(Color.YELLOW)
	sprite.texture = ImageTexture.create_from_image(img)
	root.add_child(sprite)
	
	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 3.0
	col.shape = shape
	root.add_child(col)
	
	var scene := PackedScene.new()
	scene.pack(root)
	return scene

static func _build_fireball_scene() -> PackedScene:
	var root := Area2D.new()
	root.name = "Projectile"
	root.set_script(PROJECTILE_SCRIPT)
	
	var sprite := Sprite2D.new()
	sprite.name = "Sprite2D"
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.ORANGE_RED)
	sprite.texture = ImageTexture.create_from_image(img)
	root.add_child(sprite)
	
	var col := CollisionShape2D.new()
	col.name = "CollisionShape2D"
	var shape := CircleShape2D.new()
	shape.radius = 5.0
	col.shape = shape
	root.add_child(col)
	
	var scene := PackedScene.new()
	scene.pack(root)
	return scene

static func spawn_bullet(from: Vector2, dir: Vector2, damage: int = 10, speed: float = 400.0, lifetime: float = 2.0) -> Projectile:
	_ensure_scenes()
	var p := _bullet_scene.instantiate() as Projectile
	p.global_position = from
	p.direction = dir.normalized()
	p.damage = damage
	p.speed = speed
	p.lifetime = lifetime
	return p

static func spawn_fireball(from: Vector2, dir: Vector2, damage: int = 25, speed: float = 300.0, lifetime: float = 3.0) -> Projectile:
	_ensure_scenes()
	var p := _fireball_scene.instantiate() as Projectile
	p.global_position = from
	p.direction = dir.normalized()
	p.damage = damage
	p.speed = speed
	p.lifetime = lifetime
	return p
