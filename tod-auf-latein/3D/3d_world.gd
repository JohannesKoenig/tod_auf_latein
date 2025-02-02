extends Node3D

@onready var double_door = $Museum/Room5/Doors/DoubleDoor2

# Called when the node enters the scene tree for the first time.
func _ready():
	double_door.is_open = false
	Events.game_finished.connect(_on_game_finished)
	for i in range(1, 6):
		Events.finish_level(i)


func _on_game_finished():
	double_door.is_open = true


func _on_area_3d_body_entered(body):
	get_tree().change_scene_to_file("res://3D/study_room.tscn")
