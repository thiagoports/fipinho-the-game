extends Node

var camera = null
var player1 = null 

var players = {
	"Fipinho": preload("res://scenes/chars/Fipinho.tscn"),
}

var stages = preload("res://scenes/stages/Unifip.tscn")

func _ready():
	print("Global settings")

func loadPlayer1(context, character, pos):
	player1 = players[character].instantiate()
	player1.position = pos
	context.add_child(player1)

func loadStage(context, character):
	var stage = stages.instantiate()

	# Procura pela câmera de forma segura
	camera = stage.get_node_or_null("Camera3D")
	if camera:
		camera.current = true
	else:
		push_error("⚠️ 'Camera3D' não encontrada no stage: %s" % character)

	context.add_child(stage)

	var theme = stage.get_node_or_null("Theme")
	if theme:
		theme.play()
	else:
		push_error("⚠️ 'Theme' não encontrado no stage: %s" % character)

func _process(delta):
	if player1 and camera:
		camera.position = player1.position
