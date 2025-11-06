extends CharacterBody2D

@export var speed: int = 800
var direction: int = 1

func _ready():
	$Sprite2D.flip_h = direction == -1

func _physics_process(delta):
	position.x += direction * speed * delta
	
	var collision = move_and_collide(Vector2.ZERO)
	if collision:
		if collision.collider.is_in_group("enemies"):
			collision.collider.queue_free()
		queue_free()

func _on_Notifier_screen_exited():
	queue_free()
