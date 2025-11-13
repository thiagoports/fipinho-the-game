extends CharacterBody2D

@export var velocidade: int = 800
@export var direction: int = 1
@export var dano: int = 25
var shooter = null

func _ready():
	$Sprite2D.flip_h = direction == -1

func _physics_process(delta):
	var movimento = Vector2(direction * velocidade * delta, 0)
	var colisao = move_and_collide(movimento)
	if colisao:
		var alvo = colisao.get_collider()
		if alvo and alvo != shooter and alvo.is_in_group("enemies") and alvo.has_method("tomar_dano"):
			alvo.tomar_dano(dano)
		queue_free()

func _on_Notifier_screen_exited():
	queue_free()
