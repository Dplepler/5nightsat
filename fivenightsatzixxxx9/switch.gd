extends Node3D

@onready var guitar = $wardrobe/guitar_hanger5/guitar
@onready var baby = $wardrobe/guitar_hanger5/baby0
@onready var bulb = $ceiling/lightbulb/bulb
@onready var omni = $wardrobe/OmniLight3D
@onready var babyrun = $babyrun
@onready var babyrun_animation = $babyrun/AnimationPlayer
@onready var babyrun_sound = $babyrun/runningSound
@onready var shutdown_sound = $ceiling/lightbulb/shutdown
@onready var chiburashka_sounds = $wardrobe/chiburashka/AudioListener3D
@onready var player = $player/CharacterBody3D

var chib_pressed: bool = false

func _ready() -> void:
	level_chiburashka()
	await get_tree().create_timer(64).timeout # wait for intro
	
	baby.visible = false
	babyrun.visible = true
	babyrun_animation.play("mixamo_com")
	babyrun_sound.play()

func level_baby() -> void:
	guitar.visible = false
	bulb.visible = false
	baby.visible = true
	omni.visible = true
	shutdown_sound.play()

func level_chiburashka() -> void:
	var children = chiburashka_sounds.get_children()
	var index = randi_range(0, children.size() - 1)
	
	chib_pressed = false
	
	children[index].play()
	var result := await Promise.any([_create_promise(get_tree().create_timer(children[index].stream.get_length()).timeout), _create_promise(player.chib_sig)]).wait()
	children[index].stop()
	
	if !chib_pressed:
		jumpscare()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_character_body_3d_chib_sig() -> void:
	chib_pressed = true

func _create_promise(promise_sig : Signal):
	return Promise.new(
		func(resolve: Callable, reject: Callable):
		await promise_sig
		resolve.call()
	)

func jumpscare():
	get_tree().quit()
