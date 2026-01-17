extends Node

@onready var player = $AudioStreamPlayer

func reproducir(cancion: AudioStream):
	# Si ya está sonando la misma canción, no hacemos nada (así no se reinicia)
	if player.stream == cancion and player.playing:
		return
	
	# Si es una canción distinta, la cambiamos y le damos al play
	player.stream = cancion
	player.play()

func detener():
	player.stop()
