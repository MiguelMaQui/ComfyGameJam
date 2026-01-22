extends Control

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
			ir_al_juego()

func ir_al_juego():
	get_tree().change_scene_to_file("res://Escenas/escena1_main.tscn")
