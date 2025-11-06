extends Node2D

var timer
var sequence = []
var moves = {
	"ataque" : ["punch"],
	"especial"  : ["down", "punch"],
}

func _ready():

	Global.loadStage(self, "Fipinho")
	
	Global.loadPlayer1( self, "Fipinho", Vector2(192,343))

	self._config_timer()

func _config_timer():
	timer = Timer.new()
	add_child(timer)
	
	timer.wait_time = 0.3
	timer.one_shot = true
	
	timer.connect("timeout", Callable(self, "on_timeout"))

func on_timeout():
	self._check_sequence( sequence )
	
	sequence = []

func _add_input_to_sequence( action ):
	sequence.push_back( action )

func _play_action( action ):
	$Fipinho.set_special( action )

func _check_sequence( sequence ):
	for move_name in moves.keys():
		if sequence == moves[move_name]:
			_play_action( move_name )

func _input(event):
	if not event is InputEventKey:
		return
	if not event.is_pressed():
		return

	if event.is_action_pressed("ui_down"):
		_add_input_to_sequence("down")
	elif event.is_action_pressed("ui_right"):
		_add_input_to_sequence("front")
	elif event.is_action_pressed("ataque"):
		_add_input_to_sequence("punch")

	timer.start()
