extends Node3D

signal crawly(type_movement: int)
signal baby_die
signal shake(strength: float)

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
@onready var enemy = $crawly/enemy
@onready var enemy_animation = $crawly/enemy/crawly/AnimationPlayer
@onready var babyrun_sound = $babyrun/runningSound
@onready var babyjump_sound = $babyrun/jumpscareSound
@onready var static_sound = $static
@onready var shutdown_sound = $ceiling/lightbulb/shutdown
@onready var chiburashka_sounds = $wardrobe/chiburashka/AudioListener3D
@onready var chiburashka_laugh_sound = $wardrobe/chiburashka/jumpscare_sound
@onready var enemy_scare_sound = $crawly/enemy/scareSound

@onready var player = $player/CharacterBody3D

var baby_inprogress = false
var chiburashka_inprogress = false
var crawly_inprogress = false

var chib_pressed: bool = false
var flash_pressed: bool = false
var egg_flicker_amount = 0
var enemy_killed: bool = false
var game : bool = true

const JUMPSCARE_DURATION = 2
const DEFAULT_SHAKE = 0.7

func _ready() -> void:
	
	level_baby()
	await get_tree().create_timer(64).timeout # wait for intro
	
	#scheduler()
	
func scheduler() -> void:
	var level_chance = 20
	var time_elapsed = 0
	var laps = 0
	var levels = [level_baby, level_chiburashka, level_crawly]
	while game:
		await get_tree().create_timer(1).timeout # wait for intro
		time_elapsed += 1
		if 1 == randi_range(1, level_chance):
			levels[randi_range(0, levels.size() - 1)].call()
		if time_elapsed >= 40:
			level_chance -= 2
			time_elapsed = 0
			laps += 1
		
		if laps == 8:
			win()
	
func win() -> void:
	get_tree().quit()

func level_baby() -> void:
	if baby_inprogress:
		return
	baby_inprogress = true
	
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
		baby_inprogress = false
	
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
	
	emit_signal("shake", DEFAULT_SHAKE)
	await get_tree().create_timer(JUMPSCARE_DURATION).timeout
	emit_signal("shake", DEFAULT_SHAKE)
	jumpscare()

func level_crawly() -> void:
	if crawly_inprogress:
		return
	crawly_inprogress = true
			
	emit_signal("crawly", randi_range(0, 1))
	await get_tree().create_timer(4.5).timeout
	if !enemy_killed:
		level_crawly_lose()
	else:
		crawly_inprogress = false
		
func level_crawly_lose() -> void:
	enemy.get_parent().position = Vector3(-1, 1.8, -0.615)
	enemy.get_parent().rotation_degrees = Vector3(0, 0, 0)
	enemy.position = Vector3(0, 0, 0)
	enemy.rotation_degrees = Vector3(73, 92, -1.2)
	enemy.scale = Vector3(650, 650, 650)
	
	static_sound.play()
	enemy_scare_sound.play()
	enemy_animation.set_current_animation("running")
	turn_egg()
	enemy.visible = true
	emit_signal("shake", 0.2)
	await get_tree().create_timer(4).timeout
	jumpscare()

# Makes character appear or disappear with a light flicker
func move_character(character):
	bulb.visible = false
	await get_tree().create_timer(0.3).timeout
	character.visible = !character.visible
	bulb.visible = true

func level_chiburashka() -> void:
	if chiburashka_inprogress:
		return
	chiburashka_inprogress = true
	
	var children = chiburashka_sounds.get_children()
	var index = randi_range(0, children.size() - 1)
	
	chib_pressed = false
	
	children[index].play()
	await Promise.any([_create_promise(get_tree().create_timer(children[index].stream.get_length()).timeout), _create_promise(player.chib_sig)]).wait()
	children[index].stop()
	
	if !chib_pressed:
		level_chiburashka_lose()
	else:
		chiburashka_inprogress = false

func level_chiburashka_lose() -> void:
	move_character(chiburashka)
	chiburashka_laugh_sound.play()
	
	await get_tree().create_timer(randf_range(1, 3)).timeout
	shutdown()
	
	await get_tree().create_timer(randf_range(1, 20)).timeout # Chiburashka will jump randomly
	
	static_sound.play()
	
	chiburashka.visible = true
	chiburashka_scary.visible = true
	turn_egg()
	
	emit_signal("shake", DEFAULT_SHAKE)
	await get_tree().create_timer(JUMPSCARE_DURATION).timeout
	emit_signal("shake", DEFAULT_SHAKE)
	
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

func _on_weapon_kill_crawly() -> void:
	enemy_killed = true
