extends CharacterBody2D

@export var velocidade: int = 800
@export var direction: int = 1
@export var dano: int = 25    # será setado pelo jogador ao instanciar
var shooter = null            # referência opcional para quem disparou

func _ready():
	$Sprite2D.flip_h = direction == -1

func _physics_process(delta):
	# mover o projétil de verdade
	var movimento = Vector2(direction * velocidade * delta, 0)
	var colisao = move_and_collide(movimento)
	
	# se colidiu com qualquer coisa, tratamos:
	if colisao:
		var alvo = colisao.get_collider()
		# Se atingiu um alvo válido (não atingir o próprio shooter) e o alvo faz parte do grupo "enemies"
		if alvo and alvo != shooter and alvo.is_in_group("enemies"):
			if alvo.has_method("tomar_dano"):
				alvo.tomar_dano(dano)
		# Em qualquer colisão (parede, chão, inimigo), remove o projétil
		queue_free()

func _on_Notifier_screen_exited():
	queue_free()
