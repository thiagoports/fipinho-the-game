extends CharacterBody2D

const UP 			= Vector2(0, -1)
const GRAVITY 		= 20
const SPEED 		= 200
const JUMP_HEIGHT 	= -650

var special = null
var motion = Vector2()
var hero_direction = 1  # 1 = direita, -1 = esquerda

func _ready():
	$Sprite2D.flip_h = false

func shoryuken():
	pass
	#$"../FX/Shoryuken".play()

func hadouken():
	$"../FX/Hadouken".play()
	
	var pre_hadouken = preload("res://scenes/assets/Hadouken.tscn")
	var hadouken = pre_hadouken.instantiate()

	# Define a direção do hadouken conforme o personagem está virado
	hadouken.direction = hero_direction
	
	# Posição vertical um pouco acima do chão
	hadouken.position.y = self.position.y - 10
	
	# Posição horizontal de acordo com a direção
	hadouken.position.x = self.position.x + (190 * hero_direction)

	get_parent().add_child(hadouken)

func set_special(special_name):
	print("## Special Name ##")
	print(special_name)
	self.special = special_name

func _physics_process(delta):
	motion.y += GRAVITY

	if self.special == "shoryuken":
		$Sprite2D.position.y = -70
	else:
		$Sprite2D.position.y = 0

	# Movimento e direção do personagem
	if Input.is_action_pressed("ui_left"):
		$Sprite2D.flip_h = true
		$Sprite2D.play("walking")
		motion.x = -SPEED
		hero_direction = -1  # olhando para a esquerda
	elif Input.is_action_pressed("ui_right"):
		$Sprite2D.flip_h = false
		$Sprite2D.play("walking")
		motion.x = SPEED
		hero_direction = 1  # olhando para a direita
	else:
		if not self.special:
			$Sprite2D.play("idle")
		else:
			if self.special == "shoryuken":
				$"../FX/Shoryuken".play()
			$Sprite2D.play(self.special)
		motion.x = 0

	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
	else:
		$Sprite2D.play("jump")

	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

func _on_Sprite_animation_finished():
	var name = $Sprite2D.get_animation()
	if name == "hadouken":
		self.hadouken()
		self.special = null
	elif name == "shoryuken":
		self.shoryuken()
		self.special = null
