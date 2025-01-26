extends CharacterBody3D

@onready var audio_stream_player_3d = $AudioStreamPlayer3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var walking_delay: float = 0.3
var _last_step: float

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Events.entered_painting:
		return

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	var look_dir = Input.get_vector("TurnLeft", "TurnRight", "LookUp", "LookDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var rotation_3D = Vector3(look_dir.y, look_dir.x , 0).normalized() * max(1, Vector3(look_dir.y, look_dir.x , 0).length()) * Vector3(1,2,1)
	rotation -= rotation_3D * delta
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if is_on_floor():
		if velocity.x != 0 or velocity.z != 0:
			var now = Time.get_unix_time_from_system()
			if now - _last_step > walking_delay:
				_last_step = now
				audio_stream_player_3d.play()

	move_and_slide()
