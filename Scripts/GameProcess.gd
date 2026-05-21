extends Control

# 节点声明
var background
var character
var text
var text_panel
var speaker
var speaker_panel
var chapter_label
var options_container

# 台本声明
var nodes: Dictionary
var current_node
var next_node
var node: Dictionary
var chapters
var current_chapter
var chapter


func _ready() -> void:
	background = $Background
	character = $Character
	text = $TextContainer/TextPanel/MarginContainer/Text
	text_panel = $TextContainer/TextPanel
	speaker = $SpeakerContainer/SpeakerPanel/MarginContainer/Speaker
	speaker_panel = $SpeakerContainer/SpeakerPanel
	chapter_label = $VBoxContainer/ChapterName
	options_container = $OptionsContainer
	
	var json_path = "res://test_script.json"
	var json_string = ""
	if not FileAccess.file_exists(json_path):
		print("文件不存在")
		
	var json_file = FileAccess.open(json_path, FileAccess.READ)
	json_string = json_file.get_as_text()
	json_file.close()
	
	var json = JSON.new()
	var err = json.parse(json_string)
	if err != OK:
		print("JSON 解析错误：", json.get_error_message(), " 位于 ", json_string, " 行号 ", json.get_error_line())
		return
		
	var data: Dictionary = json.data
	chapters = data["chapters"]
	current_chapter = data["start_chapter"]
	
	chapter_iteration()
		


func _process(_delta: float) -> void:
	pass


func chapter_iteration() -> void:
	chapter = chapters[current_chapter]
	current_node = chapter["start_node"]
	nodes = chapter["nodes"]
	node_iteration()

func node_iteration() -> void:
	if current_node == null:
		return
	elif current_node == "chapter_end":
		if chapter.has("next_chapter"):
			current_chapter = chapter["next_chapter"]
			chapter_iteration()
		else:
			return
	else:
		if current_node == null || !nodes.has(current_node):
			print("节点未找到: " + str(current_node))
			return
			
		node = nodes[current_node]
		
		if node["type"] == "dialogue":
			node_process()
		elif node["type"] == "choice":
			choice_process()
			


func node_process() -> void:
	var bg_name = node["bg"] if node.has("bg") && typeof(node["bg"]) != TYPE_NIL else null
	var character_name = node["character"] if node.has("character") && typeof(node["character"]) != TYPE_NIL else null
	var speaker_name = node["speaker"] if node.has("speaker") && typeof(node["speaker"]) != TYPE_NIL else null
	var text_name = node["text"] if node.has("text") else null

	if bg_name == null:
		background.texture = null
	else:
		background.texture = load("res://Assets/Pictures/" + bg_name + ".png")

	if character_name == null:
		character.texture = null
	else:
		character.texture = load("res://Assets/Pictures/" + character_name + ".png")

	speaker.text = speaker_name if speaker_name != null else "..."
	text.text = text_name if text_name != null else "......"
	chapter_label.text = "Chapter " + str(current_chapter)
	
	next_node = node["next"] if node.has("next") else null


func choice_process() -> void:
	var character_name = node["character"] if node.has("character") && typeof(node["character"]) != TYPE_NIL else null
	var speaker_name = node["speaker"] if node.has("speaker") && typeof(node["speaker"]) != TYPE_NIL else null
	var text_name = node["text"] if node.has("text") else null

	if character_name == null:
		character.texture = null
	else:
		character.texture = load("res://Assets/Pictures/" + character_name + ".png")

	speaker.text = speaker_name if speaker_name != null else "..."
	text.text = text_name if text_name != null else "......"
	chapter_label.text = "Chapter " + str(current_chapter)
	
	for i in node["options"].size():
		var option_btn = Button.new()
		option_btn.text = node["options"][i]["text"]
		option_btn.set_meta("option_node", node["options"][i]["next"])
		options_container.add_child(option_btn)
		
		option_btn.pressed.connect(_on_option_btn_pressed.bind(option_btn.get_meta("option_node")))

	
	next_node = node["next"] if node.has("next") else null
	


func _on_option_btn_pressed(option_node: String) -> void:
	current_node = option_node
	for child in options_container.get_children():
		child.queue_free()
		
	node_iteration()

func _on_text_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT && node["type"] == "dialogue":
		current_node = next_node
		node_iteration()
