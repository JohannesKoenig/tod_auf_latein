extends Node

var active_painting: Painting:
	set(value):
		if active_painting != value:
			active_painting = value
			active_painting_changed.emit(active_painting)
signal active_painting_changed(painting: Painting)

var entered_painting: bool:
	set(value):
		if entered_painting != value:
			entered_painting = value
			entered_painting_changed.emit(entered_painting)

signal entered_painting_changed(entered: bool)
