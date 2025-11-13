extends Node2D

var temporizador
var sequencia = []
var movimentos = {
	"ataque" : ["soco"],
	"especial"  : ["especial"],
}

@onready var vida_p1_barra = $HUD/Vida_Fipinho
@onready var vida_p2_barra = $HUD/Vida_Duolingo

var vida_p1_max = 100
var vida_p2_max = 100
var vida_p1 = vida_p1_max
var vida_p2 = vida_p2_max

func _ready():
	Global.loadStage(self, "Unifip")
	_config_timer()
	_conectar_sinais_dano()

func _has_prop(obj: Object, name: String) -> bool:
	if not obj:
		return false
	for p in obj.get_property_list():
		if p.name == name:
			return true
	return false

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
	if has_node("Fipinho"):
		$Fipinho._set_special(acao)

func _check_sequence(sequencia_local):
	for nome_movimento in movimentos.keys():
		if sequencia_local == movimentos[nome_movimento]:
			_play_action(nome_movimento)
	temporizador.start()

func _conectar_sinais_dano() -> void:
	var attempts = 0
	while (not has_node("Fipinho") or not has_node("Duolingo")) and attempts < 120:
		attempts += 1
		await get_tree().process_frame

	if not has_node("Fipinho") or not has_node("Duolingo"):
		push_warning("Jogadores não encontrados automaticamente — verifique se os nós 'Fipinho' e 'Duolingo' existem como filhos.")

	if has_node("Fipinho"):
		var f = $Fipinho
		if f.has_signal("levou_dano"):
			f.connect("levou_dano", Callable(self, "_on_fipinho_levou_dano"))
		if _has_prop(f, "vida"):
			vida_p1_max = int(f.get("vida"))
			vida_p1 = vida_p1_max

	if has_node("Duolingo"):
		var d = $Duolingo
		if d.has_signal("levou_dano"):
			d.connect("levou_dano", Callable(self, "_on_duolingo_levou_dano"))
		if _has_prop(d, "vida"):
			vida_p2_max = int(d.get("vida"))
			vida_p2 = vida_p2_max

	if has_node("HUD"):
		var hud = $HUD
		if hud.has_method("setup"):
			hud.setup(vida_p1_max, vida_p2_max)

	_atualizar_hud()

func _on_fipinho_levou_dano(valor):
	vida_p1 = clamp(vida_p1 - int(valor), 0, vida_p1_max)
	if has_node("HUD") and $HUD.has_method("set_health_p1"):
		$HUD.set_health_p1(vida_p1)
	else:
		_atualizar_hud()
	_verificar_vencedor()

func _on_duolingo_levou_dano(valor):
	vida_p2 = clamp(vida_p2 - int(valor), 0, vida_p2_max)
	if has_node("HUD") and $HUD.has_method("set_health_p2"):
		$HUD.set_health_p2(vida_p2)
	else:
		_atualizar_hud()
	_verificar_vencedor()

func _verificar_vencedor():
	if vida_p1 <= 0:
		print("Duolingo venceu!")
	elif vida_p2 <= 0:
		print("Fipinho venceu!")

func _atualizar_hud():
	if vida_p1_barra:
		vida_p1_barra.max_value = vida_p1_max
		vida_p1_barra.value = vida_p1
	if vida_p2_barra:
		vida_p2_barra.max_value = vida_p2_max
		vida_p2_barra.value = vida_p2

func resetar_partida():
	vida_p1 = vida_p1_max
	vida_p2 = vida_p2_max
	_atualizar_hud()
