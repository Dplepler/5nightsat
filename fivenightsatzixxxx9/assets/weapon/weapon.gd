extends Node3D

signal kill_crawly

@onready var camera = $".."
@onready var enemy = $"../../../../crawly/enemy"
@onready var sound = $laserSound

const WEAPON_ANIMATION_TIME = 0.4

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
		slide_and_animate()
	
func _on_main_crawly(type_movement: int) -> void:
	slide_weapon()
	visible = true
	sound.play()
	
	await get_tree().create_timer(2).timeout
	slide_and_animate()

func slide_weapon() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:z", 0.423 if visible else -0.64 , WEAPON_ANIMATION_TIME).set_ease(Tween.EASE_IN)

func slide_and_animate() -> void:
	slide_weapon()
	await get_tree().create_timer(WEAPON_ANIMATION_TIME).timeout
	visible = false
