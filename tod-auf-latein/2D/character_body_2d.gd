extends CharacterBody2D


@export var speed = 300.0
@export var jump_velocity = -500



func _physics_process(delta):
	if not Events.entered_painting:
		return 

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		
		velocity.y = jump_velocity

	velocity.x = speed
	

	move_and_slide()
