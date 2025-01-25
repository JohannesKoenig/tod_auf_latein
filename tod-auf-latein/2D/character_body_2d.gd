extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -80
@export var jump_timer = 0.0
var JUMP_TIMER_FACTOR = 15
var current_velocity = 0
var started_jumping: bool = false
var playing: bool = false


func _physics_process(delta):
	if not playing:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta * 3


	if is_on_floor():
		jump_timer = 0.0
		started_jumping = false
	
	if (Input.is_action_just_pressed("Jump") and jump_timer == 0):
		started_jumping = true

	if (Input.is_action_pressed("Jump")):
		jump_timer += delta
		if started_jumping:
			if jump_timer < 1:
				velocity.y = jump_velocity * pow((1 - jump_timer),2) * 8
	
	if Input.is_action_just_released("Jump"):
		started_jumping = false

		
	velocity.x = speed
	

	move_and_slide()
