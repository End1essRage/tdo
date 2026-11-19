extends CanvasLayer

@export var config: GameConfig

@onready var tab_container: TabContainer = $PanelContainer/TabContainer
@onready var pause_vbox: VBoxContainer = $PanelContainer/TabContainer/PauseTab/VBoxContainer
@onready var admin_vbox: VBoxContainer = $PanelContainer/TabContainer/AdminTab/VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build_pause_tab()
	_build_admin_tab()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		visible = !visible
		get_tree().paused = visible
		if visible:
			_build_admin_tab() # Обновляем значения при открытии

# --- ВКЛАДКА "PAUSE" ---
func _build_pause_tab() -> void:
	for child in pause_vbox.get_children():
		pause_vbox.remove_child(child)
		child.queue_free()
		
	var resume_btn = Button.new()
	resume_btn.text = "Продолжить"
	resume_btn.pressed.connect(func(): 
		visible = false
		get_tree().paused = false
	)
	pause_vbox.add_child(resume_btn)
	
	var quit_btn = Button.new()
	quit_btn.text = "Выйти из игры"
	quit_btn.pressed.connect(func(): get_tree().quit())
	pause_vbox.add_child(quit_btn)

# --- ВКЛАДКА "ADMIN" ---
func _build_admin_tab() -> void:
	if config == null: return

	for child in admin_vbox.get_children():
		admin_vbox.remove_child(child)
		child.queue_free()

	var title = Label.new()
	title.text = "⚙️ ADMIN SETTINGS"
	title.add_theme_font_size_override("font_size", 20)
	admin_vbox.add_child(title)

	_add_block(admin_vbox, "Player", [
		{"name": "player_speed", "type": "float", "min": 10, "max": 500, "step": 10}
	])
	
	_add_block(admin_vbox, "Dash", [
		{"name": "max_dashes", "type": "int", "min": 1, "max": 10, "step": 1},
		{"name": "player_dash_speed", "type": "float", "min": 100, "max": 1000, "step": 50}
	])
	
	_add_block(admin_vbox, "Projectiles", [
		{"name": "projectile_damage", "type": "int", "min": 1, "max": 100, "step": 1},
		{"name": "projectile_speed", "type": "float", "min": 100, "max": 1000, "step": 50}
	])
	
	_add_impact_selector(admin_vbox)
	
	# Кнопка применения
	var apply_btn = Button.new()
	apply_btn.text = "🔄 Применить и пересоздать игрока"
	apply_btn.pressed.connect(_apply_and_recreate)
	admin_vbox.add_child(apply_btn)

# Вспомогательные методы добавления (перенесены с параметром parent)
func _add_block(parent: Node, block_name: String, properties: Array) -> void:
	var label = Label.new()
	label.text = "--- " + block_name + " ---"
	parent.add_child(label)
	
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
		parent.add_child(hbox)

func _add_impact_selector(parent: Node) -> void:
	var label = Label.new()
	label.text = "--- Hit Effects ---"
	parent.add_child(label)
	
	var hbox = HBoxContainer.new()
	var opt = OptionButton.new()
	
	for i in range(config.impact_effects.size()):
		opt.add_item("Impact " + str(i + 1), i)
	
	opt.selected = config.current_impact_index
	opt.item_selected.connect(func(idx): _on_impact_selected(idx))
	
	hbox.add_child(opt)
	parent.add_child(hbox)

func _on_value_changed(prop_name: String, value: Variant) -> void:
	config.set(prop_name, value)
	# Ничего не применяем на лету, ждем кнопку

func _on_impact_selected(index: int) -> void:
	config.current_impact_index = index

# --- ПЕРЕСОЗДАНИЕ ИГРОКА ---
func _apply_and_recreate() -> void:
	# 1. Находим PlayerBuilder (или сам узел игрока)
	var builder = get_tree().current_scene.get_node_or_null("PlayerBuilder")
	if builder == null:
		push_error("PlayerBuilder не найден в сцене!")
		return
		
	# 2. Удаляем старого игрока (если он есть)
	var old_player = get_tree().get_first_node_in_group("player")
	if old_player:
		# Если PlayerBuilder создает игрока как ребенка, 
		# то лучше удалить именно его, а не из группы
		old_player.queue_free()
		# Ждем кадр, чтобы Godot успел удалить
		await get_tree().process_frame
		
	# 3. Пересоздаем игрока
	var new_player = builder.build_player()
	get_tree().current_scene.add_child(new_player) # Или add_child(builder) если билдер сам добавляет
	
	# 4. Возвращаем паузу и закрываем меню
	get_tree().paused = false
	visible = false
