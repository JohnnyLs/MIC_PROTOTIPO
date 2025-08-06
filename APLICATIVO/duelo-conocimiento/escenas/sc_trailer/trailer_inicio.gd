extends Control  # Using Control for UI consistency

@onready var video_player = $VideoStreamPlayer  # VideoStreamPlayer node
@onready var skip_button = $btn_right  # Ensure this matches the button's name

func _ready():
	# Verify nodes exist
	if video_player == null:
		push_error("Error: VideoStreamPlayer not found. Check node name.")
		return
	if skip_button == null:
		push_error("Error: Button not found. Check node name ($btn_right).")
		return
	
	# Connect signals explicitly
	if not video_player.is_connected("finished", _on_video_player_finished):
		video_player.finished.connect(_on_video_player_finished)
	if not skip_button.is_connected("pressed", _on_skip_button_pressed):
		skip_button.pressed.connect(_on_skip_button_pressed)

func _on_skip_button_pressed():
	# Called when the button is pressed
	change_to_main_scene()

func _on_video_player_finished():
	# Called when the video finishes
	change_to_main_scene()

func change_to_main_scene():
	# Change to the results scene
	GameManager.cambiar_escena("res://escenas/sc_inicio/Inicio.tscn")
	
