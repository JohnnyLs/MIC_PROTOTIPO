# res://src/GameManager.gd
extends Node

const API_BASE_URL: String = "https://server-mic-videojuego-1059486069178.us-central1.run.app/api/"

var personaje_index: int = 0
var nombre_jugador: String = ""
var personaje: String = ""
var id_partida: int = 0
var aciertos: int = 0
var errores: int = 0
var tiempo_total: float = 0.0  # En segundos

func cambiar_escena(ruta: String) -> void:
	get_tree().call_deferred("change_scene_to_file", ruta)

func get_genero_personaje() -> String:
	match personaje_index:
		0: return "hombre"
		1: return "mujer"
		_: return "hombre"

func resetear_estadisticas() -> void:
	aciertos = 0
	errores = 0
	tiempo_total = 0.0
