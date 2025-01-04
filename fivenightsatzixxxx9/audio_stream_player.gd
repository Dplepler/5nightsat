extends AudioStreamPlayer

@onready var sound_player = $"."  # Reference the AudioStreamPlayer node

func _ready():
	sound_player.stream = load("res://assets/sounds/intro.mp3")
	await get_tree().create_timer(2).timeout
	sound_player.play()

func _on_button_pressed() -> void:
	sound_player.stop()
