class_name ProgressIndicator extends Node3D


@onready var progress_light: ProgressLight = $Pivot/Lights/ProgressLight
@onready var progress_light_2: ProgressLight = $Pivot/Lights/ProgressLight2
@onready var progress_light_3: ProgressLight = $Pivot/Lights/ProgressLight3
@onready var progress_light_4: ProgressLight = $Pivot/Lights/ProgressLight4
@onready var progress_light_5: ProgressLight = $Pivot/Lights/ProgressLight5

func _process(delta):
	if Events.finished_1:
		progress_light.level_finished()
	if Events.finished_2:
		progress_light_2.level_finished()
	if Events.finished_3:
		progress_light_3.level_finished()
	if Events.finished_4:
		progress_light_4.level_finished()
	if Events.finished_5:
		progress_light_5.level_finished()
