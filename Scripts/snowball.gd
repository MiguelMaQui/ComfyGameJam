extends Area2D

@export var velocidad := 450.0
@export var vida := 2.0

var direccion: Vector2 = Vector2.RIGHT
var owner_player: Node = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direccion * velocidad * delta
	vida -= delta
	if vida <= 0:
		queue_free()

func _on_body_entered(body: Node) -> void:
	# 1. Si chocamos con el propio jugador que la disparó, ignoramos
	if body == owner_player:
		return

	# 2. Comprobamos si hemos chocado con un ENEMIGO
	if body.is_in_group("enemy"):
		# Aquí va tu lógica de hacer daño al enemigo (si tienes alguna)
		if body.has_method("recibir_impacto"): # O como se llame tu función de daño
			body.recibir_impacto()
		
		# --- SECUENCIA DE SONIDO ---
		velocidad = 0 # Frenamos la bola
		$Sprite2D.visible = false # La volvemos invisible
		$CollisionShape2D.set_deferred("disabled", true) # Desactivamos colisiones
		
		# Reproducimos el sonido SOLO aquí
		if $SFX_Impacto: 
			$SFX_Impacto.pitch_scale = randf_range(0.8, 1.2)
			$SFX_Impacto.play()
			await $SFX_Impacto.finished # Esperamos a que termine
		
		queue_free() # Adiós bola

	# 3. Si chocamos con CUALQUIER OTRA COSA (Suelo, pared, techo...)
	else:
		# Destrucción silenciosa e inmediata
		queue_free()
