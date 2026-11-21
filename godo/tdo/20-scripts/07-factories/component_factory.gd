class_name ComponentFactory
extends RefCounted

# --- Базовый примитив ---
# Создаёт Node, ставит скрипт, имя, опционально свойства, добавляет к parent.
static func attach_node(
	parent: Node,
	node_name: String,
	script: Script,
	props: Dictionary = {}
) -> Node:
	var node := Node.new()
	node.name = node_name
	node.set_script(script)
	_apply_props(node, props)
	parent.add_child(node)
	return node

# То же, но для Node2D (позиционные компоненты: InputComponent, CursorComponent)
static func attach_node2d(
	parent: Node,
	node_name: String,
	script: Script,
	props: Dictionary = {}
) -> Node2D:
	var node := Node2D.new()
	node.name = node_name
	node.set_script(script)
	_apply_props(node, props)
	parent.add_child(node)
	return node

# То же, но для Area2D (Hurtbox)
static func attach_area2d(
	parent: Node,
	node_name: String,
	script: Script,
	props: Dictionary = {}
) -> Area2D:
	var node := Area2D.new()
	node.name = node_name
	node.set_script(script)
	_apply_props(node, props)
	parent.add_child(node)
	return node

# --- Специализированные хелперы ---

# CollisionShape2D с RectangleShape2D заданного размера
static func attach_rect_collision(
	parent: Node,
	node_name: String,
	size: Vector2
) -> CollisionShape2D:
	var col := CollisionShape2D.new()
	col.name = node_name
	var rect := RectangleShape2D.new()
	rect.size = size
	col.shape = rect
	parent.add_child(col)
	return col

# AnimatedSprite2D с фреймами и стартовой анимацией
static func attach_sprite(
	parent: Node,
	node_name: String,
	frames: SpriteFrames,
	idle_anim: StringName = &"",
	nearest_filter: bool = true
) -> AnimatedSprite2D:
	var sprite := AnimatedSprite2D.new()
	sprite.name = node_name
	if nearest_filter:
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if frames:
		sprite.sprite_frames = frames
		if idle_anim != &"" and frames.has_animation(idle_anim):
			sprite.play(idle_anim)
	parent.add_child(sprite)
	return sprite

# Состояние для FSM (Node + скрипт + overrides)
static func attach_state(
	parent: Node,
	state_name: String,
	script: Script,
	overrides: Dictionary = {}
) -> Node:
	return attach_node(parent, state_name, script, overrides)

# --- Внутреннее ---

static func _apply_props(node: Object, props: Dictionary) -> void:
	for key in props:
		node.set(key, props[key])
