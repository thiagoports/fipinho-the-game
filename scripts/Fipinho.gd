extends CharacterBody2D

const CIMA = Vector2(0, -1)
const GRAVIDADE = 20
const VELOCIDADE = 200
const ALTURA_PULO = -650

var especial_ativa = null
var movimento = Vector2()
var direcao_heroi = 1
var defendendo = false
var especial_armazenada = null

func _ready():
	$Sprite2D.flip_h = false

func _input(event):
	if event.is_action_pressed("especial"):
		if especial_ativa:
			especial_armazenada = "especial"
		else:
			set_special("especial")
	elif event.is_action_pressed("ataque"):
		if especial_ativa:
			especial_armazenada = "ataque"
		else:
			set_special("ataque")
	
	if event.is_action_pressed("ui_defesa"):
		defendendo = true
	elif event.is_action_released("ui_defesa"):
		defendendo = false

func set_special(nome_especial):
	especial_ativa = nome_especial
	$Sprite2D.play(nome_especial)

func ataque():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/ataque.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()
	sfx.finished.connect(func(): sfx.queue_free())
	pass

func especial():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/especial.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()
	var pre_especial = preload("res://scenes/assets/Especial.tscn")
	var especial_inst = pre_especial.instantiate()

	especial_inst.direction = direcao_heroi
	especial_inst.position.y = self.position.y - -50
	especial_inst.position.x = self.position.x + (190 * direcao_heroi)

	get_parent().add_child(especial_inst)
	sfx.finished.connect(func(): sfx.queue_free())

func _physics_process(delta):
	movimento.y += GRAVIDADE

	if especial_ativa:
		movimento.x = 0
		$Sprite2D.play(especial_ativa)
	elif defendendo:
		movimento.x = 0
		$Sprite2D.play("ui_defesa")
	else:
		if Input.is_action_pressed("ui_left"):
			movimento.x = -VELOCIDADE
			direcao_heroi = -1
			$Sprite2D.flip_h = true
			$Sprite2D.play("walking")
		elif Input.is_action_pressed("ui_right"):
			movimento.x = VELOCIDADE
			direcao_heroi = 1
			$Sprite2D.flip_h = false
			$Sprite2D.play("walking")
		else:
			movimento.x = 0
			$Sprite2D.play("idle")

	if is_on_floor() and not defendendo and not especial_ativa:
		if Input.is_action_pressed("ui_up"):
			movimento.y = ALTURA_PULO
	else:
		if not defendendo and not especial_ativa:
			$Sprite2D.play("jump")

	set_velocity(movimento)
	set_up_direction(CIMA)
	move_and_slide()
	movimento = velocity

func _on_Sprite_animation_finished():
	var nome = $Sprite2D.get_animation()
	if nome == "especial":
		especial()
	elif nome == "ataque":
		ataque()
	
	especial_ativa = null
	
	if especial_armazenada:
		set_special(especial_armazenada)
		especial_armazenada = null
