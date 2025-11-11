extends Node

var camera = null
var jogador1 = null
var jogador2 = null

var jogadores = {
	"Fipinho": preload("res://scenes/Fipinho.tscn"),
	"Duolingo": preload("res://scenes/Duolingo.tscn"),
}

var palcos = preload("res://scenes/Unifip.tscn")

func _ready():
	print("Global settings")
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://music/trilha_sonora.mp3")
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(func(): sfx.queue_free())

func loadPlayer1(contexto, personagem, pos):
	jogador1 = jogadores[personagem].instantiate()
	jogador1.position = pos
	contexto.add_child(jogador1)
	
func loadPlayer2(contexto, personagem, pos):	
	jogador2 = jogadores[personagem].instantiate()
	jogador2.position = pos
	contexto.add_child(jogador2)

func loadStage(contexto, personagem):
	var palco = palcos.instantiate()
	camera = palco.get_node_or_null("Camera3D")
	if camera:
		camera.current = true
	contexto.add_child(palco)

func _process(delta):
	if jogador1 and camera:
		camera.position = jogador1.position
