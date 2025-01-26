class_name StudyRoom extends Node3D

@onready var schubert = $schubert
@export var target_rotation: Vector3
var _in_rad: Vector3
var look_up: bool = false
@onready var texture_rect = $CanvasLayer/TextureRect
@onready var animation_player = $AnimationPlayer


func _ready():
	_in_rad = Vector3(
		deg_to_rad(target_rotation.x),
		deg_to_rad(target_rotation.y),
		deg_to_rad(target_rotation.z),
	)
	texture_rect.modulate = Color(1,1,1,1)
	animation_player.play("intro")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if look_up:
		schubert.rotation.z = lerp(schubert.rotation.z, _in_rad.z , delta)

func start_looking_up():
	look_up = true

func fade_in():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(texture_rect, "modulate", Color(1,1,1,0), 4)
	tween.play()

func fade_out():
	texture_rect.modulate = Color(0,0,0,1)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(texture_rect, "modulate", Color(0,0,0,1), 4)
	tween.play()
