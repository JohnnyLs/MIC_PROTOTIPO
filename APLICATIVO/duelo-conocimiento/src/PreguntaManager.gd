extends Node

var preguntas = []

func _ready():
	cargar_preguntas()

func cargar_preguntas():
	var file = FileAccess.open("res://assets/preguntas.json", FileAccess.READ)
	if file:
		var contenido = file.get_as_text()
		preguntas = JSON.parse_string(contenido)
		file.close()
	else:
		print("No se pudo cargar el archivo de preguntas.")

func obtener_pregunta_aleatoria():
	if preguntas.size() > 0:
		return preguntas[randi() % preguntas.size()]
	return null
