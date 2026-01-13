extends Area2D
# snowball.gd - dispara, detecta colisión con enemigos y aplica efecto

@export var velocidad: float = 400.0
@export var vida: float = 2.0                  # segundos antes de autodestruirse
@export var tiempo_penalizacion: float = 0.5   # tiempo que pierde el player al matar al enemigo
@export var daño: int = 1                      # por si quieres manejar "vidas" de enemigos

# dirección en la que va: Vector2.RIGHT o Vector2.LEFT
var direccion: Vector2 = Vector2.RIGHT

# referencia al jugador que disparó (se setea desde el player al instanciar)
var owner_player: Node = null

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# mover
	global_position += direccion * velocidad * delta
	vida -= delta
	if vida <= 0.0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# ignorar colisiones con otros proyectiles, ítems, etc. (si conviene)
	if not body:
		return

	# Si el cuerpo tiene un método para recibir impacto, llamarlo.
	# Usamos "recibir_impacto" por ser explícito y no romper el resto.
	if body.has_method("recibir_impacto"):
		# avisar al enemy
		body.recibir_impacto(daño)
		# penalizar al player (muy poco tiempo)
		if owner_player and owner_player.has_method("sumar_tiempo"):
			owner_player.sumar_tiempo(-tiempo_penalizacion)
		queue_free()
		return

	# Si choca con algo que no es enemigo, solo se destruye
	queue_free()
