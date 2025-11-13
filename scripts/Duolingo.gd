extends CharacterBody2D

signal levou_dano(valor)

const CIMA = Vector2(0, -1)
const GRAVIDADE = 20
const VELOCIDADE = 200
const ALTURA_PULO = -550

var especial_ativa = ""
var movimento = Vector2.ZERO
var direcao = -1
var defendendo = false

var vida: int = 100
var dano_ataque: int = 10
var dano_especial: int = 25

func _ready():
	if $Sprite2D:
		$Sprite2D.flip_h = true
	add_to_group("player2")
	add_to_group("enemies")

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

	# Aplica dano se atingir o inimigo
	var area = get_node_or_null("Area2D")
	if area:
		for corpo in area.get_overlapping_bodies():
			if corpo != self and corpo.is_in_group("player1"):
				corpo.tomar_dano(dano_ataque)

func especial():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/especial.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()

	var pre = preload("res://scenes/Especial.tscn")
	var inst = pre.instantiate()
	# configura o projétil
	inst.direction = direcao
	inst.dano = dano_especial
	inst.shooter = self
	inst.position = Vector2(position.x + (190 * direcao), position.y - -50)
	get_parent().add_child(inst)

	sfx.finished.connect(func(): sfx.queue_free())


func tomar_dano(valor):
	# aplica redução se estiver defendendo
	var dano_final = int(valor)
	if defendendo:
		dano_final = int(dano_final * 0.5)

	# subtrai vida local e limita entre 0 e máximo (se você tiver max, use ele)
	vida = max(vida - dano_final, 0)
	print("%s vida agora: %d (reduziu %d)" % [name, vida, dano_final])

	# emite sinal para a Arena/HUD atualizar
	emit_signal("levou_dano", dano_final)

	# efeito de hit simples (piscar sprite)
	if $Sprite2D:
		$Sprite2D.modulate = Color(1,0.6,0.6) # leve flash avermelhado
		await get_tree().create_timer(0.10).timeout
		$Sprite2D.modulate = Color(1,1,1)

	# som de hit (opcional)
	if FileAccess.file_exists("res://sfx/hit.mp3"):
		var hit = AudioStreamPlayer2D.new()
		hit.stream = load("res://sfx/hit.mp3")
		hit.position = position
		get_parent().add_child(hit)
		hit.play()
		hit.finished.connect(func(): hit.queue_free())

	# morrer
	if vida <= 0:
		_morrer()


func _on_Sprite_animation_finished():
	var nome = $Sprite2D.get_animation()
	if nome == "especial":
		especial()
	elif nome == "ataque":
		ataque()
	especial_ativa = ""
	
func _morrer():
	if $Sprite2D and $Sprite2D.has_animation("death"):
		$Sprite2D.play("death")
	set_physics_process(false)
	print("%s derrubado!" % name)
