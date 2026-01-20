extends Control

func _ready():
	$VBoxContainer/BotonMenu.pressed.connect(_on_menu_pressed)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir_pressed)

func _on_salir_pressed():
	get_tree().quit()

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Escenas/menu_inicio.tscn")
