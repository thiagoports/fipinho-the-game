extends CharacterBody2D
signal levou_dano(valor)

const CIMA = Vector2(0, -1)
const GRAVIDADE = 20
const VELOCIDADE = 200
const ALTURA_PULO = -550

var especial_ativa = ""
var movimento = Vector2.ZERO
var direcao = 1
var defendendo = false

var vida: int = 100
var dano_ataque: int = 10
var dano_especial: int = 25

func _ready():
	$Sprite2D.flip_h = false

func _physics_process(delta):
	var horiz = int(Input.is_action_pressed("p1_direita")) - int(Input.is_action_pressed("p1_esquerda"))
	defendendo = Input.is_action_pressed("p1_defesa")
	movimento.x = horiz * VELOCIDADE
	if horiz != 0:
		direcao = horiz
		$Sprite2D.flip_h = direcao == -1

	if is_on_floor() and not defendendo and especial_ativa == "" and Input.is_action_just_pressed("p1_cima"):
		movimento.y = ALTURA_PULO

	if movimento.y < 0:
		movimento.y += GRAVIDADE * (0.6 if Input.is_action_pressed("p1_cima") else 1.6)
	else:
		movimento.y += GRAVIDADE

	if Input.is_action_just_pressed("p1_ataque") and especial_ativa == "":
		_set_special("ataque")
	if Input.is_action_just_pressed("p1_especial") and especial_ativa == "":
		_set_special("especial")

	var anim = ""

	if especial_ativa != "":
		anim = especial_ativa
	elif defendendo:
		anim = "defesa"
	elif not is_on_floor():
		anim = "pulo"
	elif horiz != 0:
		anim = "andando"
	else:
		anim = "parado"

	$Sprite2D.play(anim)

	set_velocity(movimento)
	set_up_direction(CIMA)
	move_and_slide()
	movimento = velocity

func _set_special(nome):
	especial_ativa = nome
	$Sprite2D.play(nome)

func ataque():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/ataque.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()
	sfx.finished.connect(func(): sfx.queue_free())

	var area = get_node_or_null("Area2D")
	if area:
		for corpo in area.get_overlapping_bodies():
			if corpo != self and corpo.is_in_group("player2"):
				corpo.tomar_dano(dano_ataque)

func especial():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/especial.mp3")
	sfx.position = position
	get_parent().add_child(sfx)
	sfx.play()

	var pre = preload("res://scenes/Especial.tscn")
	var inst = pre.instantiate()
	inst.direction = direcao
	inst.dano = dano_especial
	inst.shooter = self
	inst.position = Vector2(position.x + (190 * direcao), position.y - -50)
	get_parent().add_child(inst)

	sfx.finished.connect(func(): sfx.queue_free())

func tomar_dano(valor):
	var dano_final = int(valor)
	if defendendo:
		dano_final = int(dano_final * 0.5)
	vida = max(vida - dano_final, 0)
	print("%s vida agora: %d (reduziu %d)" % [name, vida, dano_final])
	emit_signal("levou_dano", dano_final)

	if $Sprite2D:
		$Sprite2D.modulate = Color(1,0.6,0.6)
		await get_tree().create_timer(0.10).timeout
		$Sprite2D.modulate = Color(1,1,1)

	if FileAccess.file_exists("res://sfx/hit.mp3"):
		var hit = AudioStreamPlayer2D.new()
		hit.stream = load("res://sfx/hit.mp3")
		hit.position = position
		get_parent().add_child(hit)
		hit.play()
		hit.finished.connect(func(): hit.queue_free())

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
	set_physics_process(false)
	set_process(false)
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		queue_free()
		return

	if sprite is AnimatedSprite2D:
		var sf = sprite.sprite_frames
		if sf and sf.has_animation("death"):
			if not sprite.is_connected("animation_finished", Callable(self, "_on_death_anim_finished")):
				sprite.animation_finished.connect(Callable(self, "_on_death_anim_finished"))
			sprite.play("death")
			return
		else:
			sprite.visible = false
			await get_tree().process_frame
			queue_free()
			return

	sprite.visible = false
	await get_tree().process_frame
	queue_free()

func _on_death_anim_finished(anim_name:String) -> void:
	if anim_name == "death":
		var sprite = get_node_or_null("Sprite2D")
		if sprite and sprite is AnimatedSprite2D:
			if sprite.is_connected("animation_finished", Callable(self, "_on_death_anim_finished")):
				sprite.animation_finished.disconnect(Callable(self, "_on_death_anim_finished"))
		queue_free()
