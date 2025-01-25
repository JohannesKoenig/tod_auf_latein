extends Node3D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func _process(delta):
	if Events.entered_painting:
		audio_stream_player.volume_db = lerp(audio_stream_player.volume_db, -20.0, delta)
	else:
		audio_stream_player.volume_db = lerp(audio_stream_player.volume_db, 0.0, delta)
