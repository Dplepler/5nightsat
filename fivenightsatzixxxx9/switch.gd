extends Node3D

signal baby_die

@onready var guitar = $wardrobe/guitar_hanger5/guitar
@onready var baby = $wardrobe/guitar_hanger5/baby0
@onready var bulb = $ceiling/lightbulb
@onready var omni = $wardrobe/OmniLight3D
@onready var babyrun = $babyrun
@onready var babyrun_animation = $babyrun/AnimationPlayer
@onready var flash = $desk/egg/flash

@onready var babyrun_sound = $babyrun/runningSound
@onready var babyjump_sound = $babyrun/jumpscareSound
@onready var shutdown_sound = $ceiling/lightbulb/shutdown
@onready var chiburashka_sounds = $wardrobe/chiburashka/AudioListener3D

@onready var player = $player/CharacterBody3D

var chib_pressed: bool = false
var flash_pressed: bool = false

var egg_flicker_amount = 0

func _ready() -> void:
	await get_tree().create_timer(5).timeout 
	level_baby()
	#level_chiburashka()
	await get_tree().create_timer(64).timeout # wait for intro

func level_baby() -> void:
	bulb.visible = false
	await get_tree().create_timer(0.3).timeout
	babyrun.visible = true
	bulb.visible = true
	
	flash.visible = true
	var result := await Promise.any([_create_promise(get_tree().create_timer(6).timeout), _create_promise(baby_die)]).wait()
	babyrun.visible = false
	
	if !flash_pressed:
		level_baby_lose()
	
func level_baby_lose() -> void:
	shutdown()
	await get_tree().create_timer(3).timeout
	
	babyrun.position = Vector3(12.679, 0.481, -2.553)
	babyrun.rotation_degrees = Vector3(0.3, -80.3, 0.2)
	babyrun.scale = Vector3(7, 7, 7)
	
	babyrun_sound.play()
	babyrun_animation.play("running")
	babyrun.visible = true
	
	await get_tree().create_timer(1.4).timeout
	babyrun_animation.play("jump")
	
	babyjump_sound.play()
	babyrun_sound.stop()
	
	babyrun.position = Vector3(7.418, -0.016, -2.3)
	babyrun.rotation_degrees = Vector3(-11.8, -79.3, -2)
	
	await get_tree().create_timer(0.75).timeout
	jumpscare()
	
func level_chiburashka() -> void:
	var children = chiburashka_sounds.get_children()
	var index = randi_range(0, children.size() - 1)
	
	chib_pressed = false
	
	children[index].play()
	var result := await Promise.any([_create_promise(get_tree().create_timer(children[index].stream.get_length()).timeout), _create_promise(player.chib_sig)]).wait()
	children[index].stop()
	
	if !chib_pressed:
		jumpscare()

func shutdown() -> void:
	guitar.visible = false
	bulb.visible = false
	baby.visible = true
	omni.visible = true
	shutdown_sound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#chib_sig
func _on_character_body_3d_chib_sig() -> void:
	chib_pressed = true

#baby_sig
func _on_character_body_3d_baby_sig() -> void:
	if !flash.visible:
		return
	
	var flashlight = flash.get_child(0)
	
	flashlight.visible = !flashlight.visible
	egg_flicker_amount += 1
	
	if 4 == egg_flicker_amount:
		egg_flicker_amount = 0	
		flash_pressed = true
		emit_signal("baby_die")
	
func _create_promise(promise_sig : Signal):
	return Promise.new(
		func(resolve: Callable, reject: Callable):
		await promise_sig
		resolve.call()
	)

func jumpscare():
	get_tree().quit()
