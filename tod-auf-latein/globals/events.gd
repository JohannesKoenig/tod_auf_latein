extends Node

var active_painting: Painting:
	set(value):
		if active_painting != value:
			active_painting = value
			active_painting_changed.emit(active_painting)
signal active_painting_changed(painting: Painting)
