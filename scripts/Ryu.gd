extends CharacterBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -650

var special = null               # Especial em execução
var motion = Vector2()
var hero_direction = 1           # 1 = direita, -1 = esquerda
var defending = false            # Defesa ativa
var buffered_special = null      # Ataque guardado no buffer

func _ready():
	$Sprite2D.flip_h = false

# Detecta inputs
func _input(event):
	# Ataques com buffer
	if event.is_action_pressed("hadouken"):
		if special:
			buffered_special = "hadouken"
		else:
			set_special("hadouken")
	elif event.is_action_pressed("shoryuken"):
		if special:
			buffered_special = "shoryuken"
		else:
			set_special("shoryuken")
	
	# Defesa
	if event.is_action_pressed("ui_defesa"):
		defending = true
	elif event.is_action_released("ui_defesa"):
		defending = false

# Define e inicia um especial
func set_special(special_name):
	print("## Special Name ##", special_name)
	special = special_name
	$Sprite2D.play(special)

# Função do shoryuken
func shoryuken():
	$"../FX/Shoryuken".play()
	# Aqui você pode instanciar o shoryuken se houver
	pass

# Função do hadouken
func hadouken():
	$"../FX/Hadouken".play()
	var pre_hadouken = preload("res://scenes/assets/Hadouken.tscn")
	var hadouken = pre_hadouken.instantiate()

	hadouken.direction = hero_direction
	hadouken.position.y = self.position.y - -50
	hadouken.position.x = self.position.x + (190 * hero_direction)

	get_parent().add_child(hadouken)

# Movimento e física
func _physics_process(delta):
	motion.y += GRAVITY

	# Trava movimento durante especial ou defesa
	if special:
		motion.x = 0
		$Sprite2D.play(special)
	elif defending:
		motion.x = 0
		$Sprite2D.play("ui_defesa")  # animação de defesa
	else:
		# Movimento normal
		if Input.is_action_pressed("ui_left"):
			motion.x = -SPEED
			hero_direction = -1
			$Sprite2D.flip_h = true
			$Sprite2D.play("walking")
		elif Input.is_action_pressed("ui_right"):
			motion.x = SPEED
			hero_direction = 1
			$Sprite2D.flip_h = false
			$Sprite2D.play("walking")
		else:
			motion.x = 0
			$Sprite2D.play("idle")

	# Pular se estiver no chão e não estiver defendendo ou em especial
	if is_on_floor() and not defending and not special:
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
	else:
		if not defending and not special:
			$Sprite2D.play("jump")

	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

# Quando a animação termina
func _on_Sprite_animation_finished():
	var name = $Sprite2D.get_animation()
	if name == "hadouken":
		hadouken()
	elif name == "shoryuken":
		shoryuken()
	
	special = null
	
	# Executa qualquer ataque guardado no buffer
	if buffered_special:
		set_special(buffered_special)
		buffered_special = null
