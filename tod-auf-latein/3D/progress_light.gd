class_name ProgressLight extends MeshInstance3D

var duplicate_material: StandardMaterial3D

var finished: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	duplicate_material  =  material_override.duplicate()
	duplicate_material.albedo_color = Color.RED
	material_override = duplicate_material


func level_finished():
	if not finished:
		duplicate_material.albedo_color = Color.from_string("009e53", Color.AQUAMARINE)
		finished = true


func _on_painting_finished_level():
	pass # Replace with function body.
