extends Control

var quit_popup
var main_panel
var start_panel
var load_panel
var saves_container
var del_btn

var save_status # for judging save panel status
	
func _ready() -> void:
	quit_popup = $QuitPopup
	quit_popup.visible = false
	
	main_panel = $MainPanel
	
	start_panel = $StartPanel
	start_panel.visible = false
	
	load_panel = $LoadPanel
	load_panel.visible = false
	
	saves_container = $LoadPanel/ScrollContainer/SavesContainer
	del_btn = $LoadPanel/DelBtn

func _process(_delta: float) -> void:
	pass

func _on_start_btn_pressed() -> void:
	main_panel.visible = false
	start_panel.visible = true

func _on_setting_btn_pressed() -> void:
	pass
	# get_tree().change_scene_to_file("res://Scenes/TestScene.tscn")

func _on_quit_btn_pressed() -> void:
	quit_popup.visible = true

func _on_confirm_btn_pressed() -> void:
	get_tree().quit()

func _on_cancel_btn_pressed() -> void:
	quit_popup.visible = false

func _on_return_btn_pressed() -> void:
	main_panel.visible = true
	start_panel.visible = false

func _on_load_btn_pressed() -> void:
	start_panel.visible = false
	load_panel.visible = true
	
	save_status = "save"
	del_btn.text = "删除存档"
	
	var saves = load_saves()
	if saves.size() != 0:
		for i in saves.size():
			var save_json = FileAccess.open("user://saves/" + saves[i] + ".save", FileAccess.READ)
	
			var json_string = save_json.get_as_text()
			save_json.close()
			var json = JSON.new()
			var err = json.parse(json_string)
			if err != OK:
				print("JSON 解析错误：", json.get_error_message(), " 位于 ", json_string, " 行号 ", json.get_error_line())
				return
		
			var data: Dictionary = json.data
			
			var save_btn = Button.new()
			save_btn.text = Time.get_date_string_from_unix_time(int(saves[i])) + " Chapter " + str(data["current_chapter"]) + " " + str(data["current_node"])
			save_btn.set_meta("save_name", saves[i])
			saves_container.add_child(save_btn)
			save_btn.pressed.connect(_on_save_btn_pressed.bind(save_btn.get_meta("save_name")))
	
	else:
		var label = Label.new()
		label.text = "啥都木有..."
		saves_container.add_child(label)
		

func load_saves() -> Variant:
	var saves = []
	var dir = DirAccess.open("user://saves/")
	
	if dir:
		dir.list_dir_begin()
		var save = dir.get_next()
		
		while save != "":
			if !dir.current_is_dir() && save.get_extension().to_lower() == "save".to_lower():
				saves.append(save.get_basename())
			
			save = dir.get_next()
		dir.list_dir_end()
	else:
		print("失败: ", "user://saves/")
	
	return saves


func _on_save_btn_pressed(save_name: String):
	if (save_status == "del"):
		if FileAccess.file_exists("user://saves/" + save_name + ".save"):
			var error = DirAccess.remove_absolute("user://saves/" + save_name + ".save")
			if error == OK:
				print("文件删除成功")
			else:
				print("删除失败，错误代码: ", error)
		else:
			print("文件不存在")
		
		_on_return_btn_2_pressed()
		_on_load_btn_pressed()
		return
	
	var save_json = FileAccess.open("user://saves/" + save_name + ".save", FileAccess.READ)
	
	var json_string = save_json.get_as_text()
	save_json.close()
	var json = JSON.new()
	var err = json.parse(json_string)
	if err != OK:
		print("JSON 解析错误：", json.get_error_message(), " 位于 ", json_string, " 行号 ", json.get_error_line())
		return
		
	var data: Dictionary = json.data
	
	var game = load("res://Scenes/GameProcess.tscn")
	var game_instance = game.instantiate()
	
	game_instance.current_chapter = data["current_chapter"]
	game_instance.current_node = data["current_node"]
	game_instance.game_timestamp = save_name
	
	get_tree().root.add_child(game_instance)
	get_tree().current_scene = game_instance
	queue_free()

func _on_return_btn_2_pressed() -> void:
	load_panel.visible = false
	for child in saves_container.get_children():
		child.queue_free()
	start_panel.visible = true


func _on_new_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/GameProcess.tscn")


func _on_continue_btn_pressed() -> void:
	var saves = load_saves()
	if saves.is_empty():
		print("没有存档")
		return
	_on_save_btn_pressed(saves.max())
	
	
func _on_del_btn_pressed() -> void:
	if save_status == "del":
		save_status = "save"
		del_btn.text = "删除存档"
		return
	save_status = "del"
	del_btn.text = "退出删除"
