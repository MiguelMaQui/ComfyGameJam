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
	if body == owner_player:
		return
	
	if body.has_method("recibir_impacto"):
		body.recibir_impacto()
	queue_free()
