extends Control

func _ready():
	# Al principio el menú está oculto
	visible = false
	
	$VBoxContainer/BotonContinuar.pressed.connect(_on_continuar_pressed)
	$VBoxContainer/BotonMenu.pressed.connect(_on_menu_pressed)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir_pressed)

func _input(event):
	# Detectamos si pulsan "ui_cancel" (normalmente ESC)
	if event.is_action_pressed("ui_cancel"):
		cambiar_pausa()

func cambiar_pausa():
	# Invertimos el estado de pausa del árbol
	var esta_pausado = not get_tree().paused
	get_tree().paused = esta_pausado
	
	# Mostramos u ocultamos el menú según corresponda
	visible = esta_pausado

func _on_continuar_pressed():
	cambiar_pausa()

func _on_menu_pressed():
	# Antes de salir, quitamos la pausa o el juego seguirá congelado en el menú
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Escenas/menu_inicio.tscn")
	
func _on_salir_pressed():
	get_tree().quit()
