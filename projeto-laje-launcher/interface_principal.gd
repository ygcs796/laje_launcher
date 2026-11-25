extends Control

@onready var grid_container = $CenterContainer/GridContainer
var base_dir := OS.get_executable_path().get_base_dir()
var pid := -1

func _ready():
	if OS.has_feature("editor"):
		base_dir = ProjectSettings.globalize_path("res://")  # teste no editor: JSON na raiz do projeto
	else:
		base_dir = OS.get_executable_path().get_base_dir()

	var json_path = base_dir.path_join("games.json")
	if not FileAccess.file_exists(json_path):
		_show_error("Não achei o games.json em:\n" + json_path)
		return

	var games = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	if games == null:
		_show_error("games.json inválido (confira vírgulas e aspas).")
		return

	for g in games:
		var btn := Button.new()
		btn.text = g.name
		btn.custom_minimum_size = Vector2(300, 300)
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP

		var img := Image.load_from_file(base_dir.path_join(g.icon))
		if img:
			btn.icon = ImageTexture.create_from_image(img)
		else:
			btn.text += "\n(ícone não encontrado)"

		btn.pressed.connect(_launch.bind(g.exe))
		grid_container.add_child(btn)

	if grid_container.get_child_count() > 0:
		grid_container.get_child(0).grab_focus()

func _show_error(msg: String):
	var l := Label.new()
	l.text = msg
	l.add_theme_font_size_override("font_size", 28)
	grid_container.add_child(l)

func _launch(exe_rel: String):
	var exe = base_dir + "/" + exe_rel
	pid = OS.create_process(exe, [])
	if pid > 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

func _process(_delta):
	if pid > 0 and not OS.is_process_running(pid):
		pid = -1
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
