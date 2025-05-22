extends Node

var personaje_index: int = 0  # Esta es la variable global que guarda el personaje seleccionado
var nombre_jugador: String = ""

func cambiar_escena(ruta: String) -> void:
	# Método más seguro usando el sistema nativo de Godot
	get_tree().call_deferred("change_scene_to_file", ruta)


func get_genero_personaje() -> String:
	# Convierte el índice a género para el jugador.gd
	match personaje_index:
		0:
			return "hombre"
		1:
			return "mujer"
		_:
			return "hombre"  # Por defecto
