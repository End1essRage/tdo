extends CanvasLayer

@export var config: GameConfig
@export var player: Player # Ссылка на игрока, чтобы применять изменения на лету

@onready var panel: PanelContainer = $PanelContainer
@onready var vbox: VBoxContainer = $PanelContainer/VBoxContainer

func _ready() -> void:
	# Скрываем меню по умолчанию
	visible = false
	_build_ui()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Кнопка Esc
		visible = !visible
		# Пауза, пока меню открыто
		get_tree().paused = visible

func _build_ui() -> void:
	if config == null:
		return

	# Очищаем старые элементы
	for child in vbox.get_children():
		child.queue_free()

	# Заголовок
	var title = Label.new()
	title.text = "⚙️ ADMIN MENU"
	title.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title)

	# Блок "Player"
	_add_block("Player", [
		{"name": "player_speed", "type": "float", "min": 10, "max": 500, "step": 10}
	])
	
	# Блок "Dash"
	_add_block("Dash", [
		{"name": "max_dashes", "type": "int", "min": 1, "max": 10, "step": 1},
		{"name": "player_dash_speed", "type": "float", "min": 100, "max": 1000, "step": 50}
	])
	
	# Блок "Projectiles"
	_add_block("Projectiles", [
		{"name": "projectile_damage", "type": "int", "min": 1, "max": 100, "step": 1},
		{"name": "projectile_speed", "type": "float", "min": 100, "max": 1000, "step": 50}
	])
	
	# Блок "Hit Effects" (выбор из массива)
	_add_impact_selector()
	
	# Блок "UI"
	# ... (если нужно менять палитру)

func _add_block(block_name: String, properties: Array) -> void:
	var label = Label.new()
	label.text = "--- " + block_name + " ---"
	vbox.add_child(label)
	
	for prop in properties:
		var hbox = HBoxContainer.new()
		var name_label = Label.new()
		name_label.text = prop["name"] + ": "
		hbox.add_child(name_label)
		
		var control: Control
		if prop["type"] == "int":
			var spin = SpinBox.new()
			spin.min_value = prop["min"]
			spin.max_value = prop["max"]
			spin.step = prop["step"]
			spin.value = config.get(prop["name"])
			spin.value_changed.connect(func(val): _on_value_changed(prop["name"], int(val)))
			control = spin
		else:
			var slider = HSlider.new()
			slider.min_value = prop["min"]
			slider.max_value = prop["max"]
			slider.step = prop["step"]
			slider.value = config.get(prop["name"])
			slider.custom_minimum_size.x = 200
			slider.value_changed.connect(func(val): _on_value_changed(prop["name"], val))
			control = slider
			
		hbox.add_child(control)
		vbox.add_child(hbox)

func _add_impact_selector() -> void:
	var label = Label.new()
	label.text = "--- Hit Effects ---"
	vbox.add_child(label)
	
	var hbox = HBoxContainer.new()
	var opt = OptionButton.new()
	
	for i in range(config.impact_effects.size()):
		opt.add_item("Impact " + str(i + 1), i)
	
	opt.selected = config.current_impact_index
	opt.item_selected.connect(func(idx): _on_impact_selected(idx))
	
	hbox.add_child(opt)
	vbox.add_child(hbox)

func _on_value_changed(prop_name: String, value: Variant) -> void:
	config.set(prop_name, value)
	# Применяем изменения на лету, если игрок существует
	_apply_changes()

func _on_impact_selected(index: int) -> void:
	config.current_impact_index = index
	_apply_changes()

func _apply_changes() -> void:
	if player == null:
		return
		
	# Обновляем параметры игрока
	player.walk_speed = config.player_speed
	player.dash_speed = config.player_dash_speed
	player.max_dashes = config.max_dashes
	
	# Обновляем ShootingComponent
	var shooting = player.get_node_or_null("ShootingComponent")
	if shooting:
		var impact_path = config.impact_effects[config.current_impact_index]
		shooting.impact_frames_path = impact_path
		shooting.damage = config.projectile_damage
		shooting.bullet_speed = config.projectile_speed
		print("Применен эффект: ", impact_path)
