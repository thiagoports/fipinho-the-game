extends Control

@export var caminho_cena_principal: String = "res://scenes/Main.tscn"

@onready var cenario = get_node_or_null("Cenario")
@onready var botao_jogar = get_node_or_null("Cenario/Jogar")
@onready var logo = get_node_or_null("Cenario/Logo")

func _has_prop(obj: Object, name: String) -> bool:
	if not obj: return false
	for p in obj.get_property_list():
		if p.name == name:
			return true
	return false

func _tween_prop(obj: Object, prop: String, value, time: float, loops: bool=false, trans = Tween.TRANS_SINE, ease = Tween.EASE_IN_OUT):
	if not obj: return null
	var t = create_tween()
	if loops: t.set_loops()
	var f = t.tween_property(obj, prop, value, time)
	if f:
		f.set_trans(trans)
		f.set_ease(ease)
	return f

func _ready():
	_iniciar_animacao_logo()
	if botao_jogar:
		var pressed_cb = Callable(self, "_on_play_pressed")
		if not botao_jogar.is_connected("pressed", pressed_cb):
			botao_jogar.pressed.connect(pressed_cb)
			botao_jogar.mouse_entered.connect(Callable(self, "_on_play_mouse_entered"))
			botao_jogar.mouse_exited.connect(Callable(self, "_on_play_mouse_exited"))
		botao_jogar.grab_focus()

func _iniciar_animacao_logo():
	if not logo: return
	if logo is TextureRect:
		var base_y = logo.rect_position.y
		var t = create_tween()
		t.set_loops()
		t.tween_property(logo, "rect_position:y", base_y - 14.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(logo, "rect_position:y", base_y, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		if _has_prop(logo, "rect_scale"):
			var base_s = logo.rect_scale
			var alvo = Vector2(base_s.x * (1 + 0.04), base_s.y * (1 + 0.04))
			var t2 = create_tween(); t2.set_loops()
			t2.tween_property(logo, "rect_scale", alvo, 1.2 / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t2.tween_property(logo, "rect_scale", base_s, 1.2 / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	elif logo is Sprite2D:
		var base_y2 = logo.position.y
		var t = create_tween(); t.set_loops()
		t.tween_property(logo, "position:y", base_y2 - 14.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(logo, "position:y", base_y2, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		if _has_prop(logo, "scale"):
			var base_s = logo.scale
			var alvo_s = base_s * (1 + 0.04)
			var t2 = create_tween(); t2.set_loops()
			t2.tween_property(logo, "scale", alvo_s, 1.2 / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			t2.tween_property(logo, "scale", base_s, 1.2 / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_play_mouse_entered():
	_hover(true)

func _on_play_mouse_exited():
	_hover(false)

func _hover(entrando: bool):
	if not botao_jogar: return
	var alvo_cor = Color(1.45, 1.45, 1.45, 1.0) if entrando else Color(1,1,1,1)
	_tween_prop(botao_jogar, "modulate", alvo_cor, 0.10, false, Tween.TRANS_SINE, Tween.EASE_OUT)
	if _has_prop(botao_jogar, "rect_size"):
		var base = botao_jogar.rect_size
		var alvo_size = base * (1.18 if entrando else (1.0 / 1.18))
		_tween_prop(botao_jogar, "rect_size", alvo_size, 0.10, false, Tween.TRANS_SINE, Tween.EASE_OUT)

func _on_play_pressed():
	if FileAccess.file_exists(caminho_cena_principal):
		get_tree().change_scene_to_file(caminho_cena_principal)

func _input(event):
	if event is InputEventKey and event.is_pressed() and Input.is_action_pressed("ui_accept"):
		_on_play_pressed()
