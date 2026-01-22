extends CharacterBody2D

@export var velocidad := 80.0
@export var velocidad_persecucion := 110.0
@export var gravedad := 1200.0
@export var rango_patruya := 200.0
@export var pausa_en_giro := 0.2
@export var daño_tiempo := 3
@export var hit_cooldown := 0.6

var direccion := -1
var origen_x := 0.0
var pausa_timer := 0.0
var hit_timer := 0.0

var jugador: Node2D = null # NUEVO

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detector: Area2D = $DetectorJugador

func _ready() -> void:
	origen_x = global_position.x
	sprite.play("walk")
	_actualizar_flip()

	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	# GRAVEDAD
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	# =========================
	# IA: PERSECUCIÓN O PATRULLA
	# =========================
	if jugador:
		# IR HACIA EL JUGADOR (solo en X)
		var dir = sign(jugador.global_position.x - global_position.x)
		direccion = dir if dir != 0 else direccion
		velocity.x = direccion * velocidad_persecucion
	else:
		# PATRULLA NORMAL
		if pausa_timer > 0:
			pausa_timer -= delta
			velocity.x = 0
		else:
			velocity.x = direccion * velocidad

			if direccion < 0 and global_position.x <= origen_x - rango_patruya:
				global_position.x = origen_x - rango_patruya
				_girar()
			elif direccion > 0 and global_position.x >= origen_x + rango_patruya:
				global_position.x = origen_x + rango_patruya
				_girar()

	move_and_slide()
	_actualizar_flip()

	_aplicar_daño()

	if hit_timer > 0:
		hit_timer -= delta

# =========================
# DETECTOR DE JUGADOR
# =========================
func _on_body_entered(body):
	if body.has_method("sumar_tiempo"):
		jugador = body

func _on_body_exited(body):
	if body == jugador:
		jugador = null

func _girar() -> void:
	direccion *= -1
	pausa_timer = pausa_en_giro

func _actualizar_flip() -> void:
	sprite.flip_h = (direccion > 0)

func _aplicar_daño() -> void:
	if hit_timer > 0:
		return

	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var body = col.get_collider()
		if body and body.has_method("sumar_tiempo"):
			body.sumar_tiempo(-daño_tiempo, true)
			hit_timer = hit_cooldown
			return

func recibir_impacto() -> void:
	queue_free()
