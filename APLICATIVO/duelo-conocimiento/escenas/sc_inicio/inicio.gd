extends Control

func _ready() -> void:
	AudioManager.reproducir_musica("res://sonidos/Whispers of the Forgotten Quest.mp3")

func _on_button_pressed() -> void:
	AudioManager.reproducir_clic()
	GameManager.cambiar_escena("res://escenas/sc_seleccion/seleccion_p.tscn")
