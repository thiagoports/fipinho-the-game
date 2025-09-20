extends Area2D

var screen_size
var speed = 400
var velocity = Vector2.ZERO

func _init():
	pass
	
func _ready():
	screen_size = get_viewport_rect().size
	
func _process(delta):
	update_movement(delta)
	update_animations()
	
func update_movement(delta):
	velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_left"):
		velocity.x = -1
	if Input.is_action_pressed("move_right"):
		velocity.x = 1
	if Input.is_action_pressed("move_up"):
		velocity.y = -1
	if Input.is_action_pressed("move_down"):
		velocity.y = 1
		
	position += velocity * speed * delta
	position = position.clamp(Vector2.ZERO, screen_size)
		
func update_animations():
	# Atualizando as animações
	if velocity.length() != 0:
		if velocity.x != 0:
			$AnimatedSprite2D.play("walk")
			$AnimatedSprite2D.flip_h = velocity.x < 0
			$AnimatedSprite2D.flip_v = false
		if velocity.y != 0:
			$AnimatedSprite2D.play("up")
	else:
		$AnimatedSprite2D.stop()
