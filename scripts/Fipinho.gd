extends CharacterBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const SPEED = 200
const JUMP_HEIGHT = -650

var special = null               
var motion = Vector2()
var hero_direction = 1           
var defending = false           
var buffered_special = null      

func _ready():
	$Sprite2D.flip_h = false

func _input(event):
	if event.is_action_pressed("especial"):
		if special:
			buffered_special = "especial"
		else:
			set_special("especial")
	elif event.is_action_pressed("ataque"):
		if special:
			buffered_special = "ataque"
		else:
			set_special("ataque")
	
	if event.is_action_pressed("ui_defesa"):
		defending = true
	elif event.is_action_released("ui_defesa"):
		defending = false

func set_special(special_name):
	special = special_name
	$Sprite2D.play(special)

func ataque():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/ataque.mp3")
	sfx.position = position  
	get_parent().add_child(sfx)
	sfx.play()

	sfx.finished.connect(func(): sfx.queue_free())
	pass

func especial():
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://sfx/especial.mp3")
	sfx.position = position  
	get_parent().add_child(sfx)
	sfx.play()
	var pre_especial = preload("res://scenes/assets/Especial.tscn")
	var especial = pre_especial.instantiate()

	especial.direction = hero_direction
	especial.position.y = self.position.y - -50
	especial.position.x = self.position.x + (190 * hero_direction)

	get_parent().add_child(especial)
	sfx.finished.connect(func(): sfx.queue_free())

func _physics_process(delta):
	motion.y += GRAVITY

	if special:
		motion.x = 0
		$Sprite2D.play(special)
	elif defending:
		motion.x = 0
		$Sprite2D.play("ui_defesa") 
	else:
		if Input.is_action_pressed("ui_left"):
			motion.x = -SPEED
			hero_direction = -1
			$Sprite2D.flip_h = true
			$Sprite2D.play("walking")
		elif Input.is_action_pressed("ui_right"):
			motion.x = SPEED
			hero_direction = 1
			$Sprite2D.flip_h = false
			$Sprite2D.play("walking")
		else:
			motion.x = 0
			$Sprite2D.play("idle")

	if is_on_floor() and not defending and not special:
		if Input.is_action_pressed("ui_up"):
			motion.y = JUMP_HEIGHT
	else:
		if not defending and not special:
			$Sprite2D.play("jump")

	set_velocity(motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity

func _on_Sprite_animation_finished():
	var name = $Sprite2D.get_animation()
	if name == "especial":
		especial()
	elif name == "ataque":
		ataque()
	
	special = null
	
	if buffered_special:
		set_special(buffered_special)
		buffered_special = null
