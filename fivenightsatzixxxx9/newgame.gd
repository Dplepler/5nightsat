extends Button
@onready var loading_screen = $"../loading"
func _on_pressed() -> void:	
	get_tree().change_scene_to_packed(load("res://main.tscn"))

func _on_button_down() -> void:
	loading_screen.visible = true
