extends Node2D

signal popped

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_visible_true():
	$Sprite2D.visible = true
	$GPUParticles2D.emitting = false

func set_visible_false():
	$Sprite2D.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	$GPUParticles2D.emitting = true
	popped.emit()
	$Sprite2D.visible = false
