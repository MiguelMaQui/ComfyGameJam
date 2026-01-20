extends Area2D

@export var siguiente_escena: String = "res://Nivel2.tscn"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificamos si es el jugador (por nombre o grupo)
	if body.name == "Player" or body.is_in_group("player"):
		# IMPORTANTE: Desactivar al jugador para que no muera durante la carga
		body.set_physics_process(false)
		
		call_deferred("cambiar_nivel")

func cambiar_nivel():
	get_tree().change_scene_to_file(siguiente_escena)
