class_name DoubleDoor extends Node3D

@onready var pivot = $Pivot
@onready var pivot_2 = $Pivot2

var open_angle: float = 90
var close_angle: float = 0
@export var is_open: bool = false


func _process(delta):
	if is_open:
		_rotate_pivot(pivot, open_angle, delta)
		_rotate_pivot(pivot_2, -open_angle, delta)


func open():
	is_open = true

func close():
	is_open = false
	
	
func _rotate_pivot(pivot_node: Node3D, angle: float, delta: float):
	pivot_node.rotation.y = lerp(pivot_node.rotation.y, deg_to_rad(angle), delta)
