extends CharacterBody2D

@export var daño_tiempo: int = 3
@export var velocidad: float = 80.0
@export var gravedad: float = 1200.0
@export var rango_patruya: float = 200.0
@export var pausa_en_giro: float = 0.2
@export var hit_cooldown: float = 0.6

var _dir: int = -1 # empieza a la izquierda
var _origen_x: float = 0.0
var _pausa_timer: float = 0.0
var _hit_timer: float = 0.0

@onready var _anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	_origen_x = global_position.x
	if _anim.sprite_frames.has_animation("walk"):
		_anim.play("walk")
	_update_flip()

func _physics_process(delta: float) -> void:
	# GRAVEDAD
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	# PATRULLA CORREGIDA
	if _pausa_timer > 0.0:
		_pausa_timer -= delta
		velocity.x = 0
	else:
		velocity.x = _dir * velocidad

		# comprobamos SOLO cuando vamos a salir del rango
		if _dir < 0 and global_position.x <= _origen_x - rango_patruya:
			global_position.x = _origen_x - rango_patruya
			_girar()
		elif _dir > 0 and global_position.x >= _origen_x + rango_patruya:
			global_position.x = _origen_x + rango_patruya
			_girar()

	move_and_slide()

	_aplicar_daño_por_colision()

	if _hit_timer > 0.0:
		_hit_timer -= delta

func _girar() -> void:
	_dir *= -1
	_pausa_timer = pausa_en_giro
	_update_flip()

func _update_flip() -> void:
	# sprite mira a la izquierda por defecto
	_anim.flip_h = (_dir > 0)

func _aplicar_daño_por_colision() -> void:
	if _hit_timer > 0.0:
		return

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col and col.get_collider().has_method("sumar_tiempo"):
			col.get_collider().sumar_tiempo(-daño_tiempo)
			_hit_timer = hit_cooldown
			return
			
func _morir() -> void:
	# Reproduce animación/sonido, luego destruye
	# Si tienes animaciones:
	if _anim and _anim.sprite_frames.has_animation("die"):
		_anim.play("die")
		# esperar a que termine la animación antes de queue_free() (opcional)
		# para simplificar la matamos inmediatamente:
	queue_free()
