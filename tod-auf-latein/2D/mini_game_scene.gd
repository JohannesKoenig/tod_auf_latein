class_name MiniGameScene extends Node2D

@export var platforms_definition_file_path: String = "res://assets/platforms.json"
@export var audio_stream: AudioStream
@export var background_material: Material
@export var background_forest_material: Material
@export var background_texture: Texture = preload("res://assets/background_forest_trees.png")

@export var polygon_material: Material
@export var polygon_texture: Texture

@onready var sprite_2d = $ParallaxBackground/ParallaxLayer/Sprite2D
@onready var sprite_2d_forest = $ParallaxBackground/ParallaxLayer2/Sprite2D
@onready var kill_zone = $KillZone


var rect_height = 10000
var rect_width = 200

var _platform_definitions: Array
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

@onready var platforms = $Platforms
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var character_body_2d = $CharacterBody2D

var _player_start_position: Vector2
@onready var fader = $CharacterBody2D/Camera2D/Fader


# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_2d.material = background_material
	sprite_2d_forest.texture = background_texture
	sprite_2d_forest.material = background_forest_material
	audio_stream_player.stream = audio_stream
	audio_stream_player.volume_db = 0.0
	_player_start_position = character_body_2d.position
	if FileAccess.file_exists(platforms_definition_file_path):
		var file_content = FileAccess.get_file_as_string(platforms_definition_file_path)
		
		var dict = JSON.parse_string(file_content)
		_total_length = dict["total_length"]
		_platform_definitions = dict["platforms"]
		_generate_polygons()
	
	var audio_stream_length = audio_stream_player.stream.get_length()
	character_body_2d.speed = _total_length / audio_stream_length * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
	character_body_2d.jump_velocity = character_body_2d.jump_velocity

func _generate_polygons():
	var x_max = -INF
	var max_width = -INF
	var y_max = -INF
	for platform_definition in _platform_definitions:
		var width = platform_definition["w"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		var height = POLYGON_HEIGHT
		var x = platform_definition["x"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		
		var new_max = max(x, x_max)
		if new_max > x_max:
			max_width = max(max_width, width)
			x_max = new_max
		var y = (platform_definition["y"] + POLYGON_CANVAS_Y_OFFSET) * POLYGON_CANVAS_Y_STRETCH
		y_max = max(y_max, y)
		var polygon2d = Polygon2D.new()
		polygon2d.color = Color.RED
		polygon2d.material = polygon_material
		polygon2d.texture = polygon_texture
		polygon2d.texture_scale = Vector2(10,10)
		polygon2d.polygon = [
			Vector2(x,y),
			Vector2(x + width, y),
			Vector2(x + width, y + height),
			Vector2(x, y + height)
		]
		var polygon_static_body: StaticBody2D = StaticBody2D.new()
		var polygon_collision_shape: CollisionPolygon2D = CollisionPolygon2D.new()
		polygon_static_body.add_child(polygon_collision_shape)
		polygon_collision_shape.polygon = polygon2d.polygon
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

func play():
	character_body_2d.position = _player_start_position
	audio_stream_player.volume_db = 0
	audio_stream_player.play()
	playing = true

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

func _on_finished_level(node: Node2D):
	print("finished")
