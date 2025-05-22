extends Node

var main_duelo: Node = null

func set_main_duelo(nodo: Node) -> void:
	main_duelo = nodo

func verificar_respuesta(opcion: String) -> void:
	if main_duelo:
		main_duelo.verificar_respuesta(opcion)
	else:
		push_error("main_duelo no está asignado.")
