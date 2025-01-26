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
signal game_finished

var finished_1: bool = false
var finished_2: bool = false
var finished_3: bool = false
var finished_4: bool = false
var finished_5: bool = false

func finish_level(level: int):
	match(level):
		1:
			finished_1 = true
		2:
			finished_2 = true
		3: 
			finished_3 = true
		4:
			finished_4 = true
		5: 
			finished_5 = true
	if finished_1 and finished_2 and finished_3 and finished_4 and finished_5:
		game_finished.emit()
