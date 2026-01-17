extends Control

func _ready():
	$VBoxContainer/BotonReintentar.pressed.connect(_on_reintentar_pressed)
	$VBoxContainer/BotonMenu.pressed.connect(_on_menu_pressed)

func _on_reintentar_pressed():
	# CAMBIA ESTO por el nombre real de tu escena de juego
	get_tree().change_scene_to_file("res://Escenas/escena1_2d.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Escenas/menu_inicio.tscn")
