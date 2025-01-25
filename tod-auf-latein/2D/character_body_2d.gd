extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -200
@export var jump_timer = 0.0
var JUMP_TIMER_FACTOR = 15
var current_velocity = 0

func _physics_process(delta):
	if not Events.entered_painting:
		return 

	if not is_on_floor():
		velocity += get_gravity() * delta

	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = jump_velocity
	
	if (Input.is_action_pressed("Jump") and is_on_floor() && jump_timer < 0.25):
		current_velocity = jump_velocity * (1 + jump_timer * JUMP_TIMER_FACTOR)
		jump_timer += delta
		
	if (Input.is_action_pressed("Jump") and is_on_floor() && jump_timer >= 0.25):
		current_velocity = jump_velocity * (1 + 0.25 * JUMP_TIMER_FACTOR)
		jump_timer += delta

	#if (!Input.is_action_pressed("Jump") and is_on_floor()):
		#jump_timer = 0.0
		#current_velocity = 0
	print(current_velocity)
	if (Input.is_action_just_released("Jump") and is_on_floor()):
		velocity.y = current_velocity
		jump_timer = 0.0
		current_velocity = 0
		
	velocity.x = speed
	

	move_and_slide()
