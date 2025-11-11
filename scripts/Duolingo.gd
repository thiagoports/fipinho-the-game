# Duolingo.gd (Player 2)
extends CharacterBody2D

const CIMA = Vector2(0, -1)
const GRAVIDADE = 20
const VELOCIDADE = 200
const ALTURA_PULO = -650

var especial_ativa = null
var movimento = Vector2()
var direcao_heroi = -1
var defendendo = false
var especial_armazenada = null

func _ready():
	if $Sprite2D:
		$Sprite2D.flip_h = true

func _physics_process(delta):
	movimento.y += GRAVIDADE

	# Prioridade: especial > defesa > movimento
	if especial_ativa:
		movimento.x = 0
		if $Sprite2D:
			$Sprite2D.play(especial_ativa)
	elif Input.is_action_pressed("p2_defesa"):
		defendendo = true
		movimento.x = 0
		if $Sprite2D:
			$Sprite2D.play("ui_defesa")
	else:
		defendendo = false
		var left = Input.is_action_pressed("p2_esquerda")
		var right = Input.is_action_pressed("p2_direita")

		if left and not right:
			movimento.x = -VELOCIDADE
			direcao_heroi = -1
			if $Sprite2D:
				$Sprite2D.flip_h = true
				$Sprite2D.play("walking")
		elif right and not left:
			movimento.x = VELOCIDADE
			direcao_heroi = 1
			if $Sprite2D:
				$Sprite2D.flip_h = false
				$Sprite2D.play("walking")
		else:
			movimento.x = 0
			if $Sprite2D:
				$Sprite2D.play("idle")

	# pulo
	if is_on_floor() and not defendendo and not especial_ativa:
		if Input.is_action_just_pressed("p2_cima"):
			movimento.y = ALTURA_PULO
	else:
		if not defendendo and not especial_ativa:
			if $Sprite2D:
				$Sprite2D.play("jump")

	# ataques (gatilho)
	if Input.is_action_just_pressed("p2_ataque"):
		if especial_ativa:
			especial_armazenada = "ataque"
		else:
			set_special("ataque")

	if Input.is_action_just_pressed("p2_especial"):
		if especial_ativa:
			especial_armazenada = "especial"
		else:
			set_special("especial")

	# aplicar movimento
	set_velocity(movimento)
	set_up_direction(CIMA)
	move_and_slide()
	movimento = velocity

func set_special(nome_especial):
	especial_ativa = nome_especial
	if $Sprite2D:
		$Sprite2D.play(nome_especial)

func ataque():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/ataque.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()
	sfx.finished.connect(func(): sfx.queue_free())

func especial():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/especial.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()

	var pre_especial = preload("res://scenes/Especial.tscn")
	var especial_inst = pre_especial.instantiate()
	especial_inst.direction = direcao_heroi
	especial_inst.position.y = position.y - -50
	especial_inst.position.x = position.x + (190 * direcao_heroi)
	get_parent().add_child(especial_inst)
	sfx.finished.connect(func(): sfx.queue_free())

func _on_Sprite_animation_finished():
	if not $Sprite2D:
		return
	var nome = $Sprite2D.get_animation()
	if nome == "especial":
		especial()
	elif nome == "ataque":
		ataque()

	especial_ativa = null
	if especial_armazenada:
		set_special(especial_armazenada)
		especial_armazenada = null
