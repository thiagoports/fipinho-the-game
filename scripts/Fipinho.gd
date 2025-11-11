extends CharacterBody2D

const CIMA = Vector2(0, -1)
const GRAVIDADE = 20
const VELOCIDADE = 200
const ALTURA_PULO = -650

# --- Sequência / Combos (antes estava no main) ---
var temporizador
var sequencia = []
var movimentos = {
	"ataque" : ["soco"],
	"especial"  : ["especial"],
}

# --- Estado do personagem ---
var especial_ativa = null
var movimento = Vector2()
var direcao_heroi = 1
var defendendo = false
var especial_armazenada = null

func _ready():
	$Sprite2D.flip_h = false
	_config_timer()

func _config_timer():
	temporizador = Timer.new()
	add_child(temporizador)
	temporizador.wait_time = 0.3
	temporizador.one_shot = true
	temporizador.connect("timeout", Callable(self, "on_timeout"))

func on_timeout():
	_check_sequence(sequencia)
	sequencia = []

func _add_input_to_sequence(acao):
	sequencia.push_back(acao)

func _play_action(acao):
	# aciona o special correspondente (nome do movimento: "ataque" ou "especial")
	set_special(acao)

func _check_sequence(sequencia_local):
	for nome_movimento in movimentos.keys():
		if sequencia_local == movimentos[nome_movimento]:
			_play_action(nome_movimento)

# --- Input e controles (Player 1, usando p1_*) ---
func _input(event):
	# ataques / especial / defesa (mapeadas em InputMap como p1_*)
	if event.is_action_pressed("p1_especial"):
		if especial_ativa:
			especial_armazenada = "especial"
		else:
			set_special("especial")
	elif event.is_action_pressed("p1_ataque"):
		if especial_ativa:
			especial_armazenada = "ataque"
		else:
			set_special("ataque")
	
	if event.is_action_pressed("p1_defesa"):
		defendendo = true
	elif event.is_action_released("p1_defesa"):
		defendendo = false

	# --- coleta de inputs para sequencia (replica a lógica anterior do main):
	# usamos os nomes das ações p1_baixo / p1_direita / p1_ataque para gerar os tokens
	if not (event is InputEventKey):
		return
	if not event.is_pressed():
		return

	if event.is_action_pressed("p1_baixo"):
		_add_input_to_sequence("baixo")
	elif event.is_action_pressed("p1_direita"):
		_add_input_to_sequence("frente")
	elif event.is_action_pressed("p1_ataque"):
		_add_input_to_sequence("soco")

	temporizador.start()

# --- efeitos e animações ---
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

func especial():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/especial.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()
	var pre_especial = preload("res://scenes/Especial.tscn")
	var especial_inst = pre_especial.instantiate()

	especial_inst.direction = direcao_heroi
	especial_inst.position.y = self.position.y - -50
	especial_inst.position.x = self.position.x + (190 * direcao_heroi)

	get_parent().add_child(especial_inst)
	sfx.finished.connect(func(): sfx.queue_free())

# --- física e movimento (usa ações p1_left / p1_right / p1_up / p1_down) ---
func _physics_process(delta):
	movimento.y += GRAVIDADE

	if especial_ativa:
		movimento.x = 0
		$Sprite2D.play(especial_ativa)
	elif defendendo:
		movimento.x = 0
		$Sprite2D.play("ui_defesa")
	else:
		if Input.is_action_pressed("p1_esquerda"):
			movimento.x = -VELOCIDADE
			direcao_heroi = -1
			$Sprite2D.flip_h = true
			$Sprite2D.play("walking")
		elif Input.is_action_pressed("p1_direita"):
			movimento.x = VELOCIDADE
			direcao_heroi = 1
			$Sprite2D.flip_h = false
			$Sprite2D.play("walking")
		else:
			movimento.x = 0
			$Sprite2D.play("idle")

	if is_on_floor() and not defendendo and not especial_ativa:
		if Input.is_action_pressed("p1_cima"):
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
