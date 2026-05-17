extends Control

var quit_popup 
	
func _ready() -> void:
	quit_popup = get_node("QuitPopup")
	quit_popup.visible = false

func _process(delta: float) -> void:
	pass

func _on_start_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/MainProcess.tscn")

func _on_achv_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TestScene.tscn")

func _on_setting_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/TestScene.tscn")

func _on_quit_btn_pressed() -> void:
	quit_popup.visible = true

func _on_confirm_btn_pressed() -> void:
	get_tree().quit()

func _on_cancel_btn_pressed() -> void:
	quit_popup.visible = false
