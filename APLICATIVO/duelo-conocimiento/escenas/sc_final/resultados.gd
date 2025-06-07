extends Control

# Referencias a los botones y TextEdit
@onready var btn_volver_jugar = $btn_volver_jugar
@onready var btn_menu_principal = $btn_menu_principal
@onready var http_request = $HTTPRequest
@onready var txtEdit_nombre = $txtEdit_nombre
@onready var txtEdit_aciertos = $txtEdit_aciertos
@onready var txtEdit_errores = $txtEdit_errores
@onready var txtEdit_tiempo_total = $txtEdit_tiempo_total

func _ready():
	# Conectar las señales de los botones
	if btn_volver_jugar:
		btn_volver_jugar.pressed.connect(_on_btn_volver_jugar_pressed)
	else:
		push_error("Nodo btn_volver_jugar no encontrado. Verifica el nombre del nodo en la escena.")

	if btn_menu_principal:
		btn_menu_principal.pressed.connect(_on_btn_menu_principal_pressed)
	else:
		push_error("Nodo btn_menu_principal no encontrado. Verifica el nombre del nodo en la escena.")

	if http_request:
		http_request.request_completed.connect(_on_request_completed)
	else:
		push_error("Nodo HTTPRequest no encontrado. Verifica que se haya agregado a la escena.")

	# Verificar y cargar datos en los TextEdit
	if txtEdit_nombre:
		txtEdit_nombre.text = GameManager.nombre_jugador if GameManager.nombre_jugador != "" else "Sin nombre"
	else:
		push_error("Nodo txtEdit_nombre no encontrado.")

	if txtEdit_aciertos:
		txtEdit_aciertos.text = str(GameManager.aciertos)
	else:
		push_error("Nodo txtEdit_aciertos no encontrado.")

	if txtEdit_errores:
		txtEdit_errores.text = str(GameManager.errores)
	else:
		push_error("Nodo txtEdit_errores no encontrado.")

	if txtEdit_tiempo_total:
		# Debug para verificar el valor
		print("GameManager.tiempo_total:", GameManager.tiempo_total)
		# Convertir tiempo_total a formato mm:ss
		var minutos = int(GameManager.tiempo_total / 60)
		var segundos = int(GameManager.tiempo_total) % 60
		txtEdit_tiempo_total.text = "%02d:%02d" % [minutos, segundos]
	else:
		push_error("Nodo txtEdit_tiempo_total no encontrado.")

func _on_btn_volver_jugar_pressed():
	AudioManager.reproducir_sonido("clic2")
	# Resetear el estado del juego
	SceneBridge.set_game_result("")  # Limpiar el resultado anterior
	
	# Crear JSON para la nueva partida usando datos de GameManager
	var json_data = {
		"nombrePerfil": GameManager.nombre_jugador,
		"personaje": GameManager.personaje
	}

	var json_str = JSON.stringify(json_data)
	var headers = ["Content-Type: application/json"]

	# Enviar solicitud POST para crear una nueva partida
	var error = http_request.request(
		GameManager.API_BASE_URL + "partidas",
		headers,
		HTTPClient.METHOD_POST,
		json_str
	)

	if error != OK:
		push_error("Error al realizar la solicitud HTTP para crear nueva partida: ", error)
		# Cambiar a Main.tscn incluso si la API falla
		GameManager.cambiar_escena("res://Main.tscn")
	else:
		print("Solicitud de nueva partida enviada, esperando respuesta...")

func _on_btn_menu_principal_pressed():
	AudioManager.reproducir_sonido("clic2")
	# Resetear el estado del juego
	SceneBridge.set_game_result("")  # Limpiar el resultado anterior
	# Cargar la escena del menú principal
	GameManager.cambiar_escena("res://escenas/sc_inicio/Inicio.tscn")

func _on_request_completed(result, response_code, headers, body):
	print("Respuesta del servidor (nueva partida):", response_code)
	var body_str = body.get_string_from_utf8()
	print("Contenido:", body_str)

	# Parsear la respuesta para obtener el idPartida
	var json = JSON.new()
	var error = json.parse(body_str)
	if error != OK:
		push_error("Error al parsear JSON de la respuesta de la API de partidas: ", error)
		# Cambiar a Main.tscn incluso si el parseo falla
		GameManager.cambiar_escena("res://Main.tscn")
		return
	
	var data = json.get_data()
	if response_code == 200 and data is Dictionary and data.has("idPartida"):
		GameManager.id_partida = data["idPartida"]
		print("idPartida actualizado en GameManager:", GameManager.id_partida)
	else:
		push_error("Respuesta de la API de partidas inválida o sin idPartida: ", data)
		# Cambiar a Main.tscn incluso si la respuesta es inválida
		GameManager.cambiar_escena("res://Main.tscn")
		return
	
	# Reiniciar estadísticas antes de iniciar la nueva partida
	GameManager.resetear_estadisticas()
	
	# Cambiar a la escena del duelo
	GameManager.cambiar_escena("res://Main.tscn")
