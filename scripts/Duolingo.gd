extends CharacterBody2D

const CIMA = Vector2(0, -1)
const GRAVIDADE = 20
const VELOCIDADE = 200
const ALTURA_PULO = -550 

var especial_ativa = ""
var movimento = Vector2.ZERO
var direcao = -1
var defendendo = false

func _ready():
	if $Sprite2D:
		$Sprite2D.flip_h = true

func _physics_process(delta):
	var horiz = int(Input.is_action_pressed("p2_direita")) - int(Input.is_action_pressed("p2_esquerda"))
	defendendo = Input.is_action_pressed("p2_defesa")

	movimento.x = horiz * VELOCIDADE
	if horiz != 0:
		direcao = horiz
		$Sprite2D.flip_h = direcao == -1

	if is_on_floor() and not defendendo and especial_ativa == "" and Input.is_action_just_pressed("p2_cima"):
		movimento.y = ALTURA_PULO

	if movimento.y < 0:
		if Input.is_action_pressed("p2_cima"):
			movimento.y += GRAVIDADE * 0.6
		else:
			movimento.y += GRAVIDADE * 1.6
	else:
		movimento.y += GRAVIDADE

	if Input.is_action_just_pressed("p2_ataque") and especial_ativa == "":
		_set_special("ataque")
	if Input.is_action_just_pressed("p2_especial") and especial_ativa == "":
		_set_special("especial")

	var anim = "idle"
	if especial_ativa != "":
		anim = especial_ativa
	elif defendendo:
		anim = "ui_defesa"
	elif not is_on_floor():
		anim = "jump"
	elif horiz != 0:
		anim = "walking"
	$Sprite2D.play(anim)

	set_velocity(movimento)
	set_up_direction(CIMA)
	move_and_slide()
	movimento = velocity

func _set_special(nome):
	especial_ativa = nome
	if $Sprite2D:
		$Sprite2D.play(nome)

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

	var pre = preload("res://scenes/Especial.tscn")
	var inst = pre.instantiate()
	inst.direction = direcao
	inst.position = Vector2(position.x + (190 * direcao), position.y - -50)
	get_parent().add_child(inst)
	sfx.finished.connect(func(): sfx.queue_free())

func _on_Sprite_animation_finished():
	var nome = $Sprite2D.get_animation()
	if nome == "especial":
		especial()
	elif nome == "ataque":
		ataque()
	especial_ativa = ""
