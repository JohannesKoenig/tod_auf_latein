extends Node

@onready var label = $CanvasLayer/Label
@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("intro")
