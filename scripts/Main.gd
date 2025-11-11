extends Node2D

var temporizador
var sequencia = []
var movimentos = {
	"ataque" : ["soco"],
	"especial"  : ["especial"],
}

func _ready():
	Global.loadStage(self, "Fipinho")
	Global.loadPlayer1(self, "Fipinho", Vector2(192,343))
	Global.loadPlayer2(self, "Duolingo", Vector2(800,343))
	self._config_timer()

func _config_timer():
	temporizador = Timer.new()
	add_child(temporizador)
	temporizador.wait_time = 0.3
	temporizador.one_shot = true
	temporizador.connect("timeout", Callable(self, "on_timeout"))

func on_timeout():
	self._check_sequence(sequencia)
	sequencia = []

func _add_input_to_sequence(acao):
	sequencia.push_back(acao)

func _play_action(acao):
	$Fipinho.set_special(acao)

func _check_sequence(sequencia_local):
	for nome_movimento in movimentos.keys():
		if sequencia_local == movimentos[nome_movimento]:
			_play_action(nome_movimento)

	temporizador.start()
