extends Node

var camera = null
var player1 = null 

var players = {
	"Fipinho": preload("res://scenes/chars/Fipinho.tscn"),
}

var stages = preload("res://scenes/stages/Unifip.tscn")

func _ready():
	print("Global settings")
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://music/trilha_sonora.mp3")
	add_child(sfx) 
	sfx.play()
	sfx.finished.connect(func(): sfx.queue_free())


func loadPlayer1(context, character, pos):
	player1 = players[character].instantiate()
	player1.position = pos
	context.add_child(player1)

func loadStage(context, character):
	var stage = stages.instantiate()

	camera = stage.get_node_or_null("Camera3D")
	if camera:
		camera.current = true

	context.add_child(stage)

func _process(delta):
	if player1 and camera:
		camera.position = player1.position
