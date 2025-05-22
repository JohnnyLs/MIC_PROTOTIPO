extends Control

func _ready() -> void:
	# Ya no hacemos nada aquí, solo esperamos que el usuario presione el botón
	pass

func _on_button_pressed() -> void:
	GameManager.cambiar_escena("res://escenas/sc_seleccion/seleccion_p.tscn")
