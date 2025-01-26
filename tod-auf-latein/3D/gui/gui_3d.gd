class_name Gui_3D extends CanvasLayer

@onready var activate_icon = $ActivateIcon
@onready var panel = $Panel

func _ready():
	Events.active_painting_changed.connect(_on_active_painting_changed)
	_on_active_painting_changed(Events.active_painting)

func _on_active_painting_changed( painting: Painting):
	if painting != null:
		panel.visible = true
	else:
		panel.visible = false
