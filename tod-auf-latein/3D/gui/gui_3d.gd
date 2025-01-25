class_name Gui_3D extends CanvasLayer

@onready var activate_icon = $ActivateIcon

func _ready():
	Events.active_painting_changed.connect(_on_active_painting_changed)
	_on_active_painting_changed(Events.active_painting)

func _on_active_painting_changed( painting: Painting):
	if painting != null:
		activate_icon.visible = true
	else:
		activate_icon.visible = false
