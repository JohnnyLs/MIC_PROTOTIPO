extends Control

@onready var btn_volver = $btn_volver


func _ready() -> void:
	AudioManager.reproducir_musica("res://sonidos/Whispers of the Forgotten Quest.mp3")
	if btn_volver:
		btn_volver.pressed.connect(_on_btn_volver_pressed)
	else:
		push_error("Nodo btn_menu_principal no encontrado. Verifica el nombre del nodo en la escena.")


func _on_btn_volver_pressed() -> void:
	AudioManager.reproducir_clic()
	GameManager.cambiar_escena("res://escenas/sc_final/resultados.tscn")
