extends CharacterBody3D

@onready var player = $"../player"
@onready var crawly_animation = $crawly/AnimationPlayer
@onready var running_sound = $runningSound
@onready var laughing_sound = $laughingSound
const SPEED = 5

var type: int # type of movement (run, crawl)
var move: bool = false
var move_begin: bool = false

func _ready() -> void:
	var anim = crawly_animation.get_animation("running")
	anim.loop_mode = (Animation.LOOP_LINEAR)
	
func _process(delta: float) -> void:
	if position.distance_to(player.position) <= 1.5: # lose, TODO: should change to: if enemy didnt die after 4 seconds (logic will be implemented in switch)
		crawly_animation.stop()
		running_sound.stop()
		visible = false
		move = false
		
	if move:  # Move towards the player if it's not within stop distance
		if move_begin:
			move_begin = false
			
			running_sound.play()
			laughing_sound.play()
			crawly_animation.play("running" if type else "crawling") # Animations names are opposites lol
		
		[run, crawl][type].call()	
		move_and_slide()
	
		
func run() -> void:
	var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
		
	look_at(player.position, Vector3.UP)
	velocity = direction_to_player * SPEED

func crawl() -> void:
	velocity.z = -1
	velocity.x = -SPEED
	
# Triggered when level starts
func _on_main_crawly(type_movement: int) -> void:
	move = true
	move_begin = true
	type = type_movement
	
	match type:
		0:
			position = Vector3(6.651, 0, 3.483)
			rotation_degrees = Vector3(0, -105, 0)	
		1:
			position = Vector3(6.651, 5.822, 1.795)
			rotation_degrees = Vector3(-12.1, 88, -174.6)
		2:
			move = false
