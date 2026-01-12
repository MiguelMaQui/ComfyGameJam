extends Area2D

func _ready():
	# En Godot 4 se usa la sintaxis de "Callable"
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("sumar_tiempo"):
		body.sumar_tiempo(5) 
		queue_free()
