extends Node

var main_duelo: Node = null
var game_result: String = ""  # Almacena "victoria" o "derrota"

func set_main_duelo(nodo: Node) -> void:
	main_duelo = nodo

func get_main_duelo() -> Node:
	return main_duelo
	
func verificar_respuesta(opcion: String) -> void:
	if main_duelo:
		main_duelo.verificar_respuesta(opcion)
	else:
		push_error("main_duelo no está asignado.")

func set_game_result(result: String) -> void:
	game_result = result

func get_game_result() -> String:
	return game_result
