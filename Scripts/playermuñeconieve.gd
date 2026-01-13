extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -350.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# He subido el tiempo máximo a 30.0 para que sea el tope de la barra
var tiempo_max := 30.0
var tiempo := 30.0
var derretir_vel := 1.0

@onready var barra_tiempo = get_tree().root.find_child("ProgressBar", true, false)
# Opcional: Si añades un nodo Label dentro del CanvasLayer y lo llamas "LabelTiempo"
@onready var texto_tiempo = get_tree().root.find_child("LabelTiempo", true, false)

# =========================
# NUEVO ↓↓↓
# =========================
@export var SnowballScene: PackedScene
@export var tiempo_por_disparo := 2.5

@onready var sprite: Sprite2D = $Sprite2D
# =========================

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# =========================
	# NUEVO ↓↓↓ (flip del sprite)
	# El sprite mira a la DERECHA por defecto
	if sprite and direction != 0:
		sprite.flip_h = direction < 0
	# =========================

func _process(delta):
	# Restamos tiempo
	tiempo -= derretir_vel * delta
	
	# Actualizamos la barra
	if barra_tiempo:
		barra_tiempo.value = tiempo
		
	# NUEVO: Actualizamos el texto para dar más presión (ej: "00:25")
	if texto_tiempo:
		texto_tiempo.text = str(ceil(tiempo)) + "s" # ceil redondea hacia arriba para no mostrar decimales feos

	# Escala visual (la presión de ver cómo desaparece)
	var escala = clamp(tiempo / 30.0, 0.4, 1.0)
	scale = Vector2(escala, escala)

	if tiempo <= 0:
		morir()

	# =========================
	# NUEVO ↓↓↓ (disparo con botón derecho)
	if Input.is_action_just_pressed("shoot"):
		disparar()
	# =========================

func sumar_tiempo(cantidad):
	tiempo += cantidad
	# Limitamos al máximo para que no sea demasiado fácil
	tiempo = min(tiempo, tiempo_max)

func morir():
	# Podrías añadir un efecto de sonido de "agua" antes de reiniciar
	get_tree().reload_current_scene()

# =========================
# NUEVO ↓↓↓ (función de disparo)
# =========================
func disparar():
	if SnowballScene == null:
		return

	var bola = SnowballScene.instantiate()

	# Dirección según el flip del sprite
	var dir := 1
	if sprite and sprite.flip_h:
		dir = -1

	bola.global_position = global_position + Vector2(16 * dir, -4)
	bola.direccion = Vector2(dir, 0)
	bola.owner_player = self

	get_tree().current_scene.add_child(bola)

	# Coste pequeño de tiempo por disparar
	sumar_tiempo(-tiempo_por_disparo)
