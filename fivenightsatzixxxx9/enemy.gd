extends CharacterBody3D

@onready var player = $"../../player"
@onready var crawly_animation = $crawly/AnimationPlayer
@onready var running_sound = $runningSound
@onready var laughing_sound = $laughingSound
@onready var smoke = $"../FogVolume"
@onready var smoke_sound = $poofSound
@onready var crawly_parent = $".."

const SPEED = 5
const DENSITY = "density"

var type: int # type of movement (run, crawl)
var move: bool = false
var move_begin: bool = false
var time_elapsed = 0

func _ready() -> void:
	smoke.material.set(DENSITY, 0)
	
	crawly_animation.get_animation("running").loop_mode = (Animation.LOOP_LINEAR)
	crawly_animation.get_animation("crawling").loop_mode = (Animation.LOOP_LINEAR)
	
func _process(delta: float) -> void:
	if !move:
		return
	
	time_elapsed += delta	

	# Move towards the player if it's not within stop distance
	if move_begin:
		move_begin = false
		time_elapsed = 0	
		running_sound.play()
		laughing_sound.play()
		crawly_animation.play("running" if type else "crawling") # Animations names are opposites lol
	
	if 1.9 <= time_elapsed:
		smoke.visible = false
		stop()
	
	[run, crawl][type].call()	
	move_and_slide()
	
func run() -> void:
	var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
		
	look_at(player.position, Vector3.UP)
	velocity = direction_to_player * SPEED

func crawl() -> void:
	velocity.z = -1
	velocity.x = -SPEED

func stop() -> void:
	running_sound.stop()
	visible = false
	move = false
	crawly_animation.stop()
	
# Triggered when level starts
func _on_main_crawly(type_movement: int) -> void:
	move = true
	move_begin = true
	type = type_movement
	
	position = Vector3(0, 0, 0)
	rotation_degrees = Vector3(10.1, 28, -1.5)
	scale = Vector3(400, 400, 400)
	match type:
		0:
			crawly_parent.position = Vector3(6.651, 0, 3.483)
			crawly_parent.rotation_degrees = Vector3(0, -105, 0)	
		1:
			crawly_parent.position = Vector3(6.651, 5.822, 1.795)
			crawly_parent.rotation_degrees = Vector3(-12.1, 88, -174.6)
		2:
			move = false

# When laser hits crawly
func _on_weapon_kill_crawly() -> void:
	crawly_parent.position = global_position
	smoke_sound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(smoke.material, DENSITY, 8, 0.2)
	stop()
	tween.tween_interval(0.1)
	tween.tween_property(smoke.material, DENSITY, 0, 0.2).set_ease(Tween.EASE_IN)
