class_name Painting extends Node3D

@export var viewport_material: ShaderMaterial
@export var mini_game_scene: PackedScene
@export var platforms_definition_file_path: String = "res://assets/platforms.json"
@export var bubbles_definition_file_path: String = "res://assets/bubble_json/level1_basic_pitch.json"

@export var audio_stream: AudioStream
@export var background_material: Material
@export var background_forest_material: Material
@export var background_texture: Texture = preload("res://assets/background_forest_trees.png")
@export var platform_color: Color = Color.WHITE

var mini_game_scene_instance: MiniGameScene
@onready var painting = $Painting
@onready var sub_viewport = $SubViewport
var active: bool = false
var entered: bool = false

signal finished_level
signal counter_updated(value: int)


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
	
	if mini_game_scene:
		mini_game_scene_instance = mini_game_scene.instantiate()
		mini_game_scene_instance.platforms_definition_file_path = platforms_definition_file_path
		mini_game_scene_instance.bubbles_definition_file_path = bubbles_definition_file_path
		mini_game_scene_instance.audio_stream = audio_stream
		mini_game_scene_instance.background_forest_material = background_forest_material
		mini_game_scene_instance.background_material = background_material
		mini_game_scene_instance.background_texture = background_texture
		mini_game_scene_instance.polygon_color = platform_color
<<<<<<< HEAD
		mini_game_scene_instance.finished_level.connect(func(): finished_level.emit())
=======
		mini_game_scene_instance.counter_changed.connect(func(value): counter_updated.emit(value))
>>>>>>> add_points
		sub_viewport.add_child(mini_game_scene_instance)

	var viewport_texture = sub_viewport.get_texture()
	viewport_material = viewport_material.duplicate(true)
	viewport_material.set_shader_parameter("ViewportTexture", viewport_texture)
	painting.material_overlay = viewport_material
	
	Events.entered_painting_changed.connect(_play_mini_game)

func _process(delta):
	if active:
		if Input.is_action_just_pressed("EnterPainting") and not entered:
			entered = true
			Events.entered_painting = entered
		elif Input.is_action_just_pressed("ExitPainting") and entered:
			entered = false
			Events.entered_painting = entered
		

func _get_configuration_warnings():
	var warnings = []
	if area_3d == null:
		warnings.append("Requires area3d as child for interaction")
	return warnings

func _on_area_entered(node_3d: Node3D):
	active = true
	Events.active_painting = self

func _on_area_exited(node_3d: Node3D):
	active = false
	Events.active_painting = null

func _play_mini_game(playing: bool):
	if Events.active_painting == self and playing:
		mini_game_scene_instance.play()
	if not playing:
		if mini_game_scene_instance:
			mini_game_scene_instance.stop()
	
