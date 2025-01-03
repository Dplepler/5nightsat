extends Node3D
@onready var camera = $".."
@onready var enemy = $"../../../../crawly/enemy"
@onready var sound = $laserSound

signal kill_crawly

func _process(delta):
	if !visible:
		return
	
	var mouse_position = get_viewport().get_mouse_position()

	var mouse_ray = camera.project_ray_origin(mouse_position)
	var mouse_direction = mouse_ray + camera.project_ray_normal(mouse_position) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(mouse_ray, mouse_direction)
	query.collide_with_areas = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)
	look_at(-mouse_direction)
	
	if result and enemy.get_instance_id() == result["collider"].get_instance_id():
		sound.stop()
		emit_signal("kill_crawly")

func _on_main_crawly(type_movement: int) -> void:
	visible = true
	sound.play()
