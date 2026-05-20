extends Control

# UI声明
var background
var character
var text
var text_panel
var speaker
var speaker_panel
var chapter_label
var section_label

# 台本声明
var nodes: Dictionary
var current_node
var next_node
var node: Dictionary
var chapters
var cur_chapter
var chapter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background = $Background
	character = $Character
	text = $TextContainer/TextPanel/MarginContainer/Text
	text_panel = $TextContainer/TextPanel
	speaker = $SpeakerContainer/SpeakerPanel/MarginContainer/Speaker
	speaker_panel = $SpeakerContainer/SpeakerPanel
	chapter_label = $VBoxContainer/ChapterName
	section_label = $VBoxContainer/SectionName
	
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
	cur_chapter = data["start_chapter"]
	base_process()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func base_process() -> void:
	chapter = chapters[cur_chapter]
	current_node = chapter["start_node"]
	nodes = chapter["nodes"]
	game_process()

func game_process() -> void:
	if current_node == null || !nodes.has(current_node):
		print("节点未找到: " + str(current_node))
		return
	
	node = nodes[current_node]
	var bg_name = node["bg"] if node.has("bg") && typeof(node["bg"]) != TYPE_NIL else null
	var character_name = node["character"] if node.has("character") && typeof(node["character"]) != TYPE_NIL else null
	var speaker_name = node["speaker"] if node.has("speaker") && typeof(node["speaker"]) != TYPE_NIL else null
	var text_name = node["text"] if node.has("text") else null

	if bg_name == null:
		background.texture = null
	else:
		background.texture = load("res://Assets/Pictures/menu_bg.png")

	if character_name == null:
		character.texture = null
	else:
		character.texture = load("res://Assets/Pictures/fuu_1.png")

	speaker.text = speaker_name if speaker_name != null else "..."
	text.text = text_name if text_name != null else "......"

	chapter_label.text = "Chapter " + str(cur_chapter)
	var section_num = current_node.split("-")[0] if current_node != null else ""
	section_label.text = "Section " + section_num
		
	next_node = node["next"] if node.has("next") else null

func _on_text_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		if next_node == null:
			return
		if next_node == "end":
			if chapter.has("next_chapter"):
				cur_chapter = chapter["next_chapter"]
				base_process()
			else:
				return
		else:
			current_node = next_node
			game_process()
