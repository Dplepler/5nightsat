extends CharacterBody3D

@onready var camera = $Camera3D

const SPEED = 0.6
const ROTATION_LIMIT = 70
var last_delta = 0.0

signal chib_sig

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta: float) -> void:
	last_delta = delta
	
func _physics_process(delta: float) -> void:
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var to_rotate = clamp(-event.relative.x, deg_to_rad(-ROTATION_LIMIT), deg_to_rad(ROTATION_LIMIT))
		camera.rotation.y = lerp_angle(camera.rotation.y, to_rotate, SPEED * last_delta)
	if event is InputEventMouseButton and MOUSE_BUTTON_LEFT == event.button_index:
		var result = get_selection()
		if result and result.collider and "chib" == result.collider.name:
			emit_signal("chib_sig")
		
func get_selection():
	var worldspace = get_world_3d().direct_space_state
	var mouse = get_viewport().get_mouse_position()
	var result = worldspace.intersect_ray(PhysicsRayQueryParameters3D.create(camera.project_ray_origin(mouse), camera.project_position(mouse, 1000)))
	
	return result
