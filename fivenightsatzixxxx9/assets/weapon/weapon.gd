extends Node3D
@onready var camera = $".."

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()

	var mouse_ray = camera.project_ray_origin(mouse_position)
	var mouse_direction = camera.project_ray_normal(mouse_position)

	var intersection = mouse_ray + mouse_direction * 1000

	look_at(-intersection)
