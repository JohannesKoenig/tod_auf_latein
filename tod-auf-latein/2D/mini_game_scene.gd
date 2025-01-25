class_name MiniGameScene extends Node2D

@export var platforms_definition_file_path: String = "res://assets/platforms.json"
@export var polygon_material: Material
@export var polygon_texture: Texture
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
	for platform_definition in _platform_definitions:
		var width = platform_definition["w"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		var height = POLYGON_HEIGHT
		var x = platform_definition["x"] * POLYGON_LENGTH_MULTIPLIER * ZOOM_FACTOR
		var y = (platform_definition["y"] + POLYGON_CANVAS_Y_OFFSET) * POLYGON_CANVAS_Y_STRETCH
		
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

func play():
	audio_stream_player.volume_db = 0
	audio_stream_player.play()
	playing = true

func stop():
	var tween = create_tween()
	tween.tween_property(audio_stream_player,"volume_db", -40, 1)
	tween.play()
	await tween.finished
	audio_stream_player.stop()
	playing = false


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
