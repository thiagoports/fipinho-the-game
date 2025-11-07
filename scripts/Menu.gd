extends Control

@export var main_scene_path: String = "res://scenes/Main.tscn" 
@onready var play_button = $Cenario/Jogar 

func _ready():
	if play_button:
		play_button.pressed.connect(_on_PlayButton_pressed)

func _on_PlayButton_pressed():
	get_tree().change_scene_to_file(main_scene_path)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		if Input.is_action_pressed("ui_accept"):
			_on_PlayButton_pressed()
