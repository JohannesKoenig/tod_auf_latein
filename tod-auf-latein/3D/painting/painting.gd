class_name Painting extends Node3D

@export var viewport_material: StandardMaterial3D
@export var mini_game_scene: PackedScene
@onready var painting = $Painting
@onready var sub_viewport = $SubViewport
var active: bool = false

var area_3d: Area3D:
	set(value):
		if area_3d != value:
			area_3d = value
			update_configuration_warnings()

# Called when the node enters the scene tree for the first time.
func _ready():
	for child in get_children():
		if child is Area3D:
			area_3d = child
	
	if area_3d != null:
		area_3d.body_entered.connect(_on_area_entered)
		area_3d.body_exited.connect(_on_area_exited)
	
	var mini_game_scene_instance = mini_game_scene.instantiate()
	sub_viewport.add_child(mini_game_scene_instance)

	var viewport_texture = sub_viewport.get_texture()
	viewport_material.albedo_texture = viewport_texture
	painting.material_overlay = viewport_material


func _get_configuration_warnings():
	var warnings = []
	if area_3d == null:
		warnings.append("Requires area3d as child for interaction")
	return warnings

func _on_area_entered(node_3d: Node3D):
	active = true

func _on_area_exited(node_3d: Node3D):
	active = false
