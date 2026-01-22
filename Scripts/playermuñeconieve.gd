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

@onready var sfx_disparo = $SFX_Disparo
@onready var sfx_muerte = $SFX_Muerte
@onready var sfx_impacto = $SFX_Impacto

# =========================
# NUEVO ↓↓↓
# =========================
@export var SnowballScene: PackedScene
@export var tiempo_por_disparo := 2.5

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
# =========================

func _ready():
	# Carga la música del nivel (si es distinta)
	var musica = load("res://Sonidos/festive-winter-music-451671.mp3")
	if MusicManager:
		MusicManager.reproducir(musica)
		
	# Arrancamos con la animación de estar quieto
	if anim:
		anim.play("idle")

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
	# NUEVA LÓGICA DE ANIMACIÓN
	# =========================
	if anim:
		# 1. Gestionar el Flip (Mirar izquierda/derecha)
		if direction != 0:
			anim.flip_h = direction < 0
			
		# 2. Gestionar qué animación suena
		# Si nos estamos moviendo (velocity.x no es 0) -> Walk
		if velocity.x != 0:
			anim.play("walk")
		else:
			# Si estamos parados -> Idle
			anim.play("idle")
		
		# (Opcional) Si tuvieras animación de salto, podrías ponerla aquí:
		# if not is_on_floor():
		# 	anim.play("jump")

func _process(delta):
	# Restamos tiempo
	tiempo -= derretir_vel * delta
	
	# Evitamos que el tiempo baje de 0 visualmente (para que no ponga -00:01 antes de morir)
	var tiempo_visual = max(0.0, tiempo)
	
# Actualizamos la barra (visual)
	if barra_tiempo:
		barra_tiempo.value = tiempo_visual
		
# ==========================================
	# NUEVO: Formato de Reloj (Minutos:Segundos)
	# ==========================================
	if texto_tiempo:
		# 1. Calculamos los minutos (división entera entre 60)
		var minutos: int = int(tiempo_visual) / 60
		
		# 2. Calculamos los segundos restantes (el resto de la división)
		var segundos: int = int(tiempo_visual) % 60
		
		# 3. Creamos el texto con formato
		# "%02d" significa: "Pon un número entero de 2 dígitos. Si es menor de 10, pon un 0 delante".
		texto_tiempo.text = "%02d:%02d" % [minutos, segundos]
	
	# ==========================================

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

# Añadimos el parámetro "es_dano_real" que por defecto es falso
func sumar_tiempo(cantidad, es_dano_real := false):
	
	# BLOQUE DE PERDER TIEMPO (Disparo o Daño)
	if cantidad < 0:
		# 1. FEEDBACK VISUAL (Siempre ocurre: Disparo y Daño)
		if anim:
			anim.modulate = Color(1, 0, 0) # Rojo
			var tween = create_tween()
			tween.tween_property(anim, "modulate", Color(1, 1, 1), 0.2) # Volver a normal

		# 2. FEEDBACK SONORO (Solo ocurre si es daño real de enemigo)
		if es_dano_real:
			if sfx_impacto:
				sfx_impacto.pitch_scale = randf_range(0.9, 1.1)
				sfx_impacto.play()
		
	# BLOQUE DE GANAR TIEMPO (Recoger cubitos)
	if cantidad > 0:
		if anim:
			anim.modulate = Color(0.135, 0.561, 0.852, 1.0) # Azul
			var tween = create_tween()
			tween.tween_property(anim, "modulate", Color(1, 1, 1), 0.2)

	tiempo += cantidad
	# Limitamos al máximo
	tiempo = min(tiempo, tiempo_max)

func morir():
	set_physics_process(false)
	set_process(false)
	
	if anim:
		anim.visible = false # Ocultamos el muñeco visualmente
	
	if sfx_muerte:
		sfx_muerte.play()
		await sfx_muerte.finished
	# await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://Escenas/game_over.tscn")

# =========================
# NUEVO ↓↓↓ (función de disparo)
# =========================
func disparar():
	if SnowballScene == null:
		return
	
	if sfx_disparo:
		sfx_disparo.pitch_scale = randf_range(0.8, 1.2) 
		sfx_disparo.play()

	var bola = SnowballScene.instantiate()

# Dirección según el flip del AnimatedSprite2D
	var dir := 1
	if anim and anim.flip_h:
		dir = -1

	bola.global_position = global_position + Vector2(16 * dir, -4)
	bola.direccion = Vector2(dir, 0)
	bola.owner_player = self

	get_tree().current_scene.add_child(bola)

	# Coste pequeño de tiempo por disparar
	sumar_tiempo(-tiempo_por_disparo)
