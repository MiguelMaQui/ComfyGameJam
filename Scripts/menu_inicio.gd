extends Control

func _ready():
	# Conectamos las señales de los botones
	$VBoxContainer/BotonJugar.pressed.connect(_on_jugar_pressed)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir_pressed)
	
	# Carga la música del menú
	var musica = load("res://Sonidos/festive-winter-music-451671.mp3")
	MusicManager.reproducir(musica)

func _on_jugar_pressed():
	# CAMBIA "res://world.tscn" POR LA RUTA DE TU NIVEL DE JUEGO
	get_tree().change_scene_to_file("res://Escenas/escena1_2d.tscn")

func _on_salir_pressed():
	get_tree().quit()
