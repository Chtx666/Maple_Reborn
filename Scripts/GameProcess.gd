extends Control

var background
var character
var text
var text_panel
var speaker
var speaker_panel
var nodes: Dictionary
var current_node
var next_node
var node: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	background = $Background
	character = $Character
	text = $TextContainer/TextPanel/MarginContainer/Text
	text_panel = $TextContainer/TextPanel
	speaker = $SpeakerContainer/SpeakerPanel/MarginContainer/Speaker
	speaker_panel = $SpeakerContainer/SpeakerPanel
	
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
	nodes = data["nodes"]
	current_node = data["start_node"]
	game_process()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	
	if speaker_name == null:
		speaker_panel.visible = false
	else:
		speaker.text = speaker_name
		speaker_panel.visible = true
		
	if text_name == null:
		text_panel.visible = false
	else:
		text.text = text_name
		text_panel.visible = true
		
	next_node = node["next"] if node.has("next") else null


func _on_text_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.pressed && event.button_index == MOUSE_BUTTON_LEFT:
		if next_node == null:
			return
		current_node = next_node
		game_process()
