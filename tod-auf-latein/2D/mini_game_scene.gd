class_name MiniGameScene extends Node2D

@export var points = 0:
	set(value):
		points = value
		counter_changed.emit(value)
@export var platforms_definition_file_path: String = "res://assets/platforms.json"
@export var bubbles_definition_file_path: String = "res://assets/bubble_json/level1_basic_pitch.json"

@export var audio_stream: AudioStream
@export var background_material: Material
@export var background_forest_material: Material
@export var background_texture: Texture = preload("res://assets/background_forest_trees.png")

@export var polygon_material: Material
@export var polygon_texture: Texture
@export var polygon_color: Color = Color.WHITE

@onready var bubble_particles: PackedScene = preload("res://2D/platform_particles.tscn")

@onready var sprite_2d = $ParallaxBackground/ParallaxLayer/Sprite2D
@onready var sprite_2d_forest = $ParallaxBackground/ParallaxLayer2/Sprite2D
@onready var kill_zone = $KillZone
@onready var bubble_2d: Node2D = $Bubble

@onready var gpu_particles_2d = $CharacterBody2D/GPUParticles2D

signal counter_changed(value: int)

signal playing_changed(value: bool)
signal finished_level

var rect_height = 10000
var rect_width = 200
var ROUNDING: int = 10

var _platform_definitions: Array
var _bubble_definitions: Array
var _total_length: float
var ZOOM_FACTOR: int = 3
var POLYGON_HEIGHT: int = 40
var POLYGON_LENGTH_MULTIPLIER: int = 10
var POLYGON_CANVAS_Y_STRETCH: int = 40
var POLYGON_CANVAS_Y_OFFSET: int = -60
var playing: bool = false:
	set(value):
		playing = value
		character_body_2d.playing = value
		playing_changed.emit(value)

@onready var platforms = $Platforms
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var character_body_2d = $CharacterBody2D

var _player_start_position: Vector2
@onready var fader = $CharacterBody2D/Camera2D/Fader


# Called when the node enters the scene tree for the first time.
func _ready():
	playing_changed.connect(_on_playing_changed)
	_on_playing_changed(playing)
	sprite_2d.material = background_material
	sprite_2d_forest.texture = background_texture
	sprite_2d_forest.material = background_forest_material
	audio_stream_player.stream = audio_stream
	audio_stream_player.volume_db = 0.0

	gpu_particles_2d.modulate = polygon_color
	_player_start_position = character_body_2d.position
	if FileAccess.file_exists(platforms_definition_file_path):
		var file_content = FileAccess.get_file_as_string(platforms_definition_file_path)
		
		var dict = JSON.parse_string(file_content)
		_total_length = dict["total_length"]
		_platform_definitions = dict["platforms"]
		_generate_polygons()
		character_body_2d.position = _player_start_position
	
	if FileAccess.file_exists(bubbles_definition_file_path):
		var file_content = FileAccess.get_file_as_string(bubbles_definition_file_path)
		
		var dict = JSON.parse_string(file_content)
		_bubble_definitions = dict["platforms"]
		_generate_bubbles()
	
	
	var audio_stream_length = audio_stream_player.stream.get_length()
	character_body_2d.speed = _total_length / audio_stream_length * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
	character_body_2d.jump_velocity = character_body_2d.jump_velocity

func _generate_polygons():
	var x_max = -INF
	
	var max_width = -INF
	var y_max = -INF
	for index in range(len(_platform_definitions)):
		var platform_definition = _platform_definitions[index]
			
		var width = platform_definition["w"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		var height = POLYGON_HEIGHT
		var x = platform_definition["x"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		var y = (platform_definition["y"] + POLYGON_CANVAS_Y_OFFSET) * POLYGON_CANVAS_Y_STRETCH
		if index == 0:
			_player_start_position.y = y - 20
		y_max = max(y_max, y)
		
		var new_max = max(x, x_max)
		if new_max > x_max:
			max_width = max(max_width, width)
			x_max = new_max
		var polygon2d = Polygon2D.new()
		polygon2d.color = Color.RED
		polygon2d.material = polygon_material.duplicate()
		polygon2d.material.set_shader_parameter("color", polygon_color)
		polygon2d.texture = polygon_texture
		polygon2d.texture_scale = Vector2(10,10)
		polygon2d.polygon = [
			Vector2(x,y + ROUNDING),
			#Vector2(x + ROUNDING,y + ROUNDING),
			Vector2(x + ROUNDING,y),
			
			Vector2(x + width - ROUNDING, y),
			#Vector2(x + width - ROUNDING, y + ROUNDING),
			Vector2(x + width, y + ROUNDING),

			Vector2(x + width, y + height - ROUNDING),
			#Vector2(x + width - ROUNDING, y + height - ROUNDING),
			Vector2(x + width - ROUNDING, y + height ),
			
			Vector2(x + ROUNDING, y + height ),
			#Vector2(x + ROUNDING, y + height - ROUNDING),
			Vector2(x , y + height - ROUNDING),
			
		]
		var polygon_static_body: StaticBody2D = StaticBody2D.new()
		var polygon_collision_shape: CollisionPolygon2D = CollisionPolygon2D.new()
		polygon_static_body.add_child(polygon_collision_shape)
		polygon_collision_shape.polygon = polygon2d.polygon
		var bubble_particles_instance: PlatformParticles = bubble_particles.instantiate()
		bubble_particles_instance.process_material = bubble_particles_instance.process_material.duplicate(true)
		bubble_particles_instance.process_material.emission_box_extents.x = width / 2
		polygon2d.add_child(bubble_particles_instance)
		bubble_particles_instance.position = Vector2(x + width / 2,y + height)
		playing_changed.connect(bubble_particles_instance.on_playing_changed)
		bubble_particles_instance.modulate = polygon_color
		bubble_particles_instance.on_playing_changed(playing)
		polygon2d.add_child(polygon_static_body)
		platforms.add_child(polygon2d)
	kill_zone.position.y = y_max
	
	var max_point = Vector2(x_max + max_width, -rect_height/4)
	var area_2D = Area2D.new()
	var collision_shape = CollisionShape2D.new()

	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(rect_width, rect_height)
	collision_shape.shape = rectangle_shape
	area_2D.add_child(collision_shape)
	area_2D.set_collision_mask_value(2, true)
	area_2D.set_collision_mask_value(1, false)
	area_2D.body_entered.connect(_on_finished_level)
	add_child(area_2D)
	area_2D.global_position = max_point

func _generate_bubbles():
	print("bubblehenlo")
	$Bubbles.modulate = polygon_color
	for bubble in _bubble_definitions:
		var new_bubble = bubble_2d.duplicate()
		var x = bubble["x"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		var y = (bubble["y"] + POLYGON_CANVAS_Y_OFFSET) * POLYGON_CANVAS_Y_STRETCH - 50
		new_bubble.position = Vector2(x, y)
		new_bubble.popped.connect(_on_popped.bind())
		$Bubbles.add_child(new_bubble)
	
func play():
	character_body_2d.position = _player_start_position
	audio_stream_player.volume_db = 0
	audio_stream_player.play()
	playing = true
	set_bubbles_visible()
	points = 0

func set_bubbles_visible():
	for bubble in $Bubbles.get_children():
		bubble.set_visible_true()

func stop():
	playing = false
	var tween = create_tween()
	tween.tween_property(audio_stream_player,"volume_db", -40, 1)
	tween.play()
	await tween.finished
	audio_stream_player.stop()
	


func _on_kill_zone_body_entered(body):
	if not playing:
		return
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fader, "modulate", Color.WHITE, 0.2)
	tween.tween_property(audio_stream_player,"volume_db", -40, 1)
	tween.play()

	await tween.finished
	audio_stream_player.stop()
	character_body_2d.position = _player_start_position
	audio_stream_player.play(0)

	tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fader, "modulate", Color(1,1,1,0), 0.2)
	tween.tween_property(audio_stream_player,"volume_db", 0, 1)
	tween.play()
	set_bubbles_visible()
	points = 0

func _on_finished_level(node: Node2D):
	finished_level.emit()

func _on_playing_changed(value: bool):
	gpu_particles_2d.emitting = value
	
func _on_popped():
	points += 1
	
	print(points)
