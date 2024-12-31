extends Node3D

signal crawly(type_movement: int)
signal baby_die
signal shake

@onready var guitar = $wardrobe/guitar_hanger5/guitar
@onready var baby = $wardrobe/guitar_hanger5/baby0
@onready var bulb = $ceiling/lightbulb
@onready var omni = $wardrobe/OmniLight3D
@onready var babyrun = $babyrun
@onready var babyrun_head = $babyrun/Armature/Object_7/FBHead
@onready var babyrun_animation = $babyrun/AnimationPlayer
@onready var flash = $desk/egg/flash
@onready var chiburashka = $wardrobe/chiburashka
@onready var chiburashka_scary = $wardrobe/chiburashka/chiburashka_scary

@onready var babyrun_sound = $babyrun/runningSound
@onready var babyjump_sound = $babyrun/jumpscareSound
@onready var static_sound = $static
@onready var shutdown_sound = $ceiling/lightbulb/shutdown
@onready var chiburashka_sounds = $wardrobe/chiburashka/AudioListener3D
@onready var chiburashka_laugh_sound = $wardrobe/chiburashka/jumpscare_sound

@onready var player = $player/CharacterBody3D

var chib_pressed: bool = false
var flash_pressed: bool = false
var egg_flicker_amount = 0

const JUMPSCARE_DURATION = 2

func _ready() -> void:
	await get_tree().create_timer(1).timeout 
	#level_baby()
	#level_chiburashka()
	level_crawly()
	await get_tree().create_timer(64).timeout # wait for intro

func level_baby() -> void:
	move_character(babyrun)
	static_sound.play()
	
	flash.visible = true
	await Promise.any([_create_promise(get_tree().create_timer(2).timeout), _create_promise(baby_die)]).wait()
	static_sound.stop()
	flash.visible = false
	
	if !flash_pressed:
		level_baby_lose()
	else:
		move_character(babyrun)
		
func level_baby_lose() -> void:
	babyrun.visible = false
	shutdown()
	
	await get_tree().create_timer(randf_range(1, 20)).timeout
	
	babyrun.position = Vector3(14, 0.481, -2.553)
	babyrun.rotation_degrees = Vector3(0.3, -70, 0.2)
	
	babyrun_sound.play()
	babyrun_head.visible = false
	babyrun_animation.play("running")
	babyrun.visible = true
	
	await get_tree().create_timer(1.4).timeout
	
	babyjump_sound.play()
	babyrun_sound.stop()

	babyrun.position = Vector3(5.892, -1.5, -2.302)
	babyrun.rotation_degrees = Vector3(-2, -91.4, 1.3)
	babyrun_head.visible = true
	
	emit_signal("shake")
	await get_tree().create_timer(JUMPSCARE_DURATION).timeout
	emit_signal("shake")
	jumpscare()

func level_crawly() -> void:
	emit_signal("crawly", randi_range(0, 1))

# Makes baby appear or disappear
func move_character(character):
	bulb.visible = false
	await get_tree().create_timer(0.3).timeout
	character.visible = !character.visible
	bulb.visible = true

func level_chiburashka() -> void:
	var children = chiburashka_sounds.get_children()
	var index = randi_range(0, children.size() - 1)
	
	chib_pressed = false
	
	children[index].play()
	await Promise.any([_create_promise(get_tree().create_timer(children[index].stream.get_length()).timeout), _create_promise(player.chib_sig)]).wait()
	children[index].stop()
	
	if !chib_pressed:
		level_chiburashka_lose()

func level_chiburashka_lose() -> void:
	move_character(chiburashka)
	chiburashka_laugh_sound.play()
	await get_tree().create_timer(randf_range(1, 20)).timeout # Chiburashka will jump randomly
	
	static_sound.play()
	
	chiburashka.visible = true
	chiburashka_scary.visible = true
	turn_egg()
	
	emit_signal("shake")
	await get_tree().create_timer(JUMPSCARE_DURATION).timeout
	emit_signal("shake")
	
	static_sound.stop()
	chiburashka_laugh_sound.stop()
	
	chiburashka_scary.visible = false
	flash.visible = false
	turn_egg()
	jumpscare()
	
func shutdown() -> void:
	guitar.visible = false
	bulb.visible = false
	baby.visible = true
	omni.visible = true
	shutdown_sound.play()

func turn_egg() -> void:
	flash.visible = true
	flash.get_child(0).visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
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
