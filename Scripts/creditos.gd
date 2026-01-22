extends Control

func _ready():
	# Conectamos las señales de los botones
	$BotonMenu.pressed.connect(_on_menu_pressed)
	
	# Carga la música del menú
	var musica = load("res://Sonidos/festive-winter-music-451671.mp3")
	MusicManager.reproducir(musica)

func _on_menu_pressed():
	# CAMBIA "res://world.tscn" POR LA RUTA DE TU NIVEL DE JUEGO
	get_tree().change_scene_to_file("res://Escenas/menu_inicio.tscn")
