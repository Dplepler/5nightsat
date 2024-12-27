extends CharacterBody3D

const SPEED = 0.1
const ROTATION_LIMIT = 70
var last_delta = 0.0

@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _process(delta: float) -> void:
	last_delta = delta
	
func _physics_process(delta: float) -> void:
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var to_rotate = clamp(-event.relative.x * SPEED, deg_to_rad(-ROTATION_LIMIT), deg_to_rad(ROTATION_LIMIT))
		camera.rotation.y = lerp_angle(camera.rotation.y, to_rotate, 2 * last_delta)
