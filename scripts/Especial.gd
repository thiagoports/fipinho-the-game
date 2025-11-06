extends CharacterBody2D

@export var velocidade: int = 800
@export var direction: int = 1

func _ready():
	$Sprite2D.flip_h = direction == -1

func _physics_process(delta):
	position.x += direction * velocidade * delta
	
	var colisao = move_and_collide(Vector2.ZERO)
	if colisao:
		if colisao.collider.is_in_group("enemies"):
			colisao.collider.queue_free()

func _on_Notifier_screen_exited():
	queue_free()
