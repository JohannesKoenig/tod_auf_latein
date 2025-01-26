extends Node3D
@onready var label_3d = $MeshInstance3D/Label3D



func update_counter(value: int):
	label_3d.text = str(value)
