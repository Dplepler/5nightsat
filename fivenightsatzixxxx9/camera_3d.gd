extends Camera3D

# Random flashing images
@onready var flash1 = $Sprite3D
@onready var flash2 = $Sprite3D2
@onready var flash3 = $Sprite3D3
@onready var flash4 = $Sprite3D4
@onready var flash5 = $Sprite3D5
@onready var flash6 = $Sprite3D6
@onready var flash7 = $Sprite3D7
@onready var flashes = [flash1, flash2, flash3, flash4, flash5, flash6, flash7]
@onready var scary_sound = $AudioStreamPlayer3D  # Reference the AudioStreamPlayer node

@onready var sound1 = $sound1
@onready var sound2 = $sound2
@onready var sound3 = $sound3
@onready var sound4 = $sound4
@onready var sound5 = $sound5
@onready var sounds = [sound1, sound2, sound3, sound4, sound5]

@onready var button = $"../../../CanvasLayer/Button"

const FLASH_DELAY = 0.2
const DEFAULT_CHANCE = 5000
const IMAGES_IN_FLASH = 5
const SOUND_AMOUNT = 5

var timer : Timer = Timer.new()
var chance_denominator : int = DEFAULT_CHANCE
var images_in_current_flash : int = 0
var last_sprite
var shake_cam : bool = false
var original_position = Vector3()
var shake_intensity: float = 0.7
var inprogress: bool = false

var promise = preload("res://promise_utils.gd")

func _on_timer_timeout():
	if last_sprite and last_sprite.visible:
		last_sprite.visible = false
	
	if IMAGES_IN_FLASH <= images_in_current_flash:
		chance_denominator = DEFAULT_CHANCE
		images_in_current_flash = 0
	
	var index = randi_range(0, chance_denominator) # number of flashes / denominator chance for an image to appear
	
	# for random sound events
	if flashes.size() < index and index <= 45:
		sounds[randi_range(0, sounds.size() - 1)].play()
		
	if index <= flashes.size() - 1 and images_in_current_flash < IMAGES_IN_FLASH and !inprogress:
		inprogress = true
		chance_denominator = 40
		
		last_sprite = flashes[index]
		last_sprite.visible = true
		images_in_current_flash += 1
		
		if 1 == images_in_current_flash:
			scary_sound.play()
		
		inprogress = false
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_position = global_transform.origin
	
	timer.wait_time = FLASH_DELAY
	timer.autostart = true
	timer.connect("timeout", _on_timer_timeout)
	
	await Promise.any([promise._create_promise(get_tree().create_timer(62).timeout), promise._create_promise(button.pressed)]).wait()
	await get_tree().create_timer(62).timeout # Wait for intro
	add_child(timer)

func _process(delta: float) -> void:
	if shake_cam:
		global_transform.origin = original_position + Vector3(
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity),
		randf_range(-shake_intensity, shake_intensity))
	
func _on_main_shake(strength: float) -> void:
	global_transform.origin = original_position
	shake_intensity = strength
	shake_cam = !shake_cam
