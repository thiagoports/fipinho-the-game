extends CharacterBody2D

@export var speed: int = 450
var direction: int = 1  # 1 = direita, -1 = esquerda

func _ready():
	# Define a orientação visual do hadouken
	if direction == -1:
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false

func _physics_process(delta):
	# Movimento contínuo na direção definida
	var collision = move_and_collide(Vector2(direction, 0) * speed * delta)

	if collision:
		if collision.collider.is_in_group("enemies"):
			collision.collider.queue_free()  # destrói o inimigo
		queue_free()  # destrói o hadouken ao colidir com qualquer coisa

func _on_Notifier_screen_exited():
	# Remove o hadouken ao sair da tela
	queue_free()
