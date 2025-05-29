extends Node

var pregunta_actual
var jugador: Node = null
var mago: Node = null

var turno_actual := "mago"
var respuesta_recibida := false

var texto_turno: RichTextLabel
var contador_turno: RichTextLabel
var temporizador: Timer
var contador_en_ejecucion := false

# Contador para el tiempo total de la partida
var tiempo_partida: float = 0.0  # En segundos
var contando_tiempo: bool = true  # Controla si se acumula tiempo

# Lista para almacenar las preguntas obtenidas de la API
var preguntas_api: Array = []

# Referencia a la escena del menú de opciones
var opciones_scene = preload("res://escenas/sc_menu_opciones/menu_opciones.tscn")
var opciones_instance = null

# Referencia a los nodos de Dialogic
var dialogic_nodes: Array[Node] = []
var dialogic_timeline_active: bool = false
var game_ended: bool = false

# Cliente HTTP para realizar solicitudes a la API
var http_request: HTTPRequest

func _ready():
	SceneBridge.set_main_duelo(self)
	if not is_inside_tree():
		push_error("Este nodo no está en el árbol de escenas al iniciar. No se puede continuar.")
		return

	# Obtener referencias a los nodos en la escena actual
	jugador = $Jugador
	mago = $Mago
	
	if jugador and jugador is Node3D:
		jugador.transform.basis = jugador.transform.basis.orthonormalized()
	if mago and mago is Node3D:
		mago.transform.basis = mago.transform.basis.orthonormalized()
	
	texto_turno = $UIDuelo/ContenedorInterfazDuelo/VBoxContainer/Turno_texto
	contador_turno = $UIDuelo/ContenedorInterfazDuelo/VBoxContainer/Contador_turno
	
	var mano_comodines = $ManoComodines
	if mano_comodines:
		mano_comodines.conectar_cartas()
		
	print("¡Cargó Main.tscn correctamente!")
	print("Jugador visible:", $Jugador.is_visible_in_tree())
	print("Mago visible:", $Mago.is_visible_in_tree())
	
	# Crear y configurar el temporizador de preguntas
	temporizador = Timer.new()
	temporizador.one_shot = true
	temporizador.timeout.connect(_on_tiempo_agotado)
	add_child(temporizador)
	
	# Crear y configurar el nodo HTTPRequest
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	
	# Reiniciar estadísticas al iniciar una nueva partida
	GameManager.resetear_estadisticas()
	
	# Obtener las preguntas de la API al iniciar
	await obtener_preguntas_api()
	
	await iniciar_turno_mago()

func _process(delta: float) -> void:
	if contador_en_ejecucion and temporizador and not temporizador.is_stopped():
		var tiempo_restante = ceil(temporizador.time_left)
		contador_turno.text = "Tiempo restante: %d" % tiempo_restante
	
	# Acumular tiempo de partida si no está pausado
	if contando_tiempo and not get_tree().paused:
		tiempo_partida += delta

func _on_dialogic_timeline_started():
	dialogic_timeline_active = true
	print("Dialogic timeline started")

func _on_dialogic_timeline_ended():
	dialogic_timeline_active = false
	print("Dialogic timeline ended")
	print("game_ended:", game_ended)
	if game_ended:
		# Guardar el tiempo total de la partida
		GameManager.tiempo_total = tiempo_partida
		print("Cambiando a escena resultados.tscn")
		get_tree().call_deferred("change_scene_to_file", "res://escenas/sc_final/resultados.tscn")

func _input(event: InputEvent) -> void:
	if not is_inside_tree():
		print("El nodo no está en el árbol de escenas al procesar la entrada.")
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("Presionado Esc en Main.tscn. Escena actual:", get_tree().current_scene.name if get_tree() else "No hay SceneTree")
		if opciones_instance == null:
			var scene_tree = get_tree()
			if scene_tree == null:
				push_error("No se pudo acceder al SceneTree. El nodo probablemente fue eliminado del árbol de escenas.")
				return
			call_deferred("_pause_and_open_menu")
		else:
			pass

func _pause_and_open_menu() -> void:
	var scene_tree = get_tree()
	if scene_tree == null:
		push_error("No se pudo acceder al SceneTree al pausar el juego.")
		return
	scene_tree.paused = true
	if temporizador and not temporizador.is_stopped():
		temporizador.paused = true
	# Pausar el conteo de tiempo
	contando_tiempo = false
	if dialogic_timeline_active:
		Dialogic.paused = true
		var root = get_tree().root
		for child in root.get_children():
			if child.name.begins_with("Dialogic"):
				for subchild in child.get_children():
					if subchild is CanvasLayer:
						dialogic_nodes.append(subchild)
						subchild.visible = false
						print("Dialogic UI node found and hidden:", subchild.name)
				break
	opciones_instance = opciones_scene.instantiate()
	if opciones_instance is CanvasLayer:
		opciones_instance.layer = 10
		add_child(opciones_instance)
	else:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 10
		canvas_layer.add_child(opciones_instance)
		add_child(canvas_layer)
	opciones_instance.connect("tree_exited", Callable(self, "_on_opciones_closed"))

func _on_opciones_closed() -> void:
	opciones_instance = null
	var scene_tree = get_tree()
	if scene_tree == null:
		push_error("No se pudo acceder al SceneTree al reanudar el juego.")
		return
	scene_tree.paused = false
	if temporizador and temporizador.paused:
		temporizador.paused = false
	# Reanudar el conteo de tiempo
	contando_tiempo = true
	if dialogic_timeline_active:
		Dialogic.paused = false
		for node in dialogic_nodes:
			node.visible = true
			print("Dialogic UI node shown again:", node.name)
		dialogic_nodes.clear()
	if texto_turno and texto_turno.modulate.a > 0:
		var tween = create_tween()
		tween.tween_property(texto_turno, "modulate:a", 0.0, 2.0).set_delay(1.0)

### API Integration ###

func obtener_preguntas_api() -> void:
	var url = "http://localhost:8082/api/preguntas/random/20"
	var error = http_request.request(url)
	if error != OK:
		push_error("Error al realizar la solicitud HTTP: ", error)
		return
	await http_request.request_completed

func _on_request_completed(result: int, response_code: int, headers: Array, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("Error en la solicitud HTTP: result=", result, ", response_code=", response_code)
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	if error != OK:
		push_error("Error al parsear JSON: ", error)
		return
	
	var data = json.get_data()
	if data is Array:
		preguntas_api = data
		for pregunta in preguntas_api:
			if pregunta.has("opciones") and pregunta["opciones"] is String:
				var opciones_json = JSON.new()
				var parse_error = opciones_json.parse(pregunta["opciones"])
				if parse_error == OK:
					pregunta["opciones"] = opciones_json.get_data()
				else:
					push_error("Error al parsear opciones JSON para pregunta ", pregunta["idPregunta"])
	else:
		push_error("La respuesta de la API no es un array: ", data)

func enviar_respuesta_api(id_pregunta: int, respuesta_dada: String, es_correcta: bool, tiempo_respuesta: int) -> void:
	var json_data = {
		"idPartida": GameManager.id_partida,
		"idPregunta": id_pregunta,
		"respuestaDada": respuesta_dada,
		"esCorrecta": es_correcta,
		"tiempoRespuesta": tiempo_respuesta
	}

	var json_str = JSON.stringify(json_data)
	var headers = ["Content-Type: application/json"]

	var error = http_request.request(
		"http://localhost:8082/api/respuestas",
		headers,
		HTTPClient.METHOD_POST,
		json_str
	)

	if error != OK:
		push_error("Error al enviar la respuesta a la API: ", error)
	else:
		print("Respuesta enviada a la API, esperando confirmación...")

### TURNOS ###

func iniciar_turno_mago():
	turno_actual = "mago"
	mostrar_turno("Turno de Conty!")
	await get_tree().create_timer(3.0).timeout
	await mago.lanzar_pregunta_animada()
	lanzar_pregunta()
	await get_tree().process_frame
	iniciar_turno_jugador()

func iniciar_turno_jugador():
	turno_actual = "jugador"
	mostrar_turno("Ahora es tu turno!")
	respuesta_recibida = false

	var tiempo_limite = pregunta_actual.get("tiempoLimite", 30)
	temporizador.start(tiempo_limite)
	iniciar_contador(tiempo_limite)

### PREGUNTAS ###

func lanzar_pregunta():
	if preguntas_api.is_empty():
		push_error("No hay preguntas disponibles en preguntas_api")
		await obtener_preguntas_api()
		if preguntas_api.is_empty():
			push_error("No se pudieron obtener preguntas de la API. Finalizando juego.")
			return
	
	pregunta_actual = preguntas_api[randi() % preguntas_api.size()]
	
	if pregunta_actual:
		Dialogic.VAR.set_variable("pregunta_texto", pregunta_actual["textoPregunta"])
		var opciones = pregunta_actual["opciones"]
		Dialogic.VAR.set_variable("opcion_a", opciones[0] if opciones.size() > 0 else "")
		Dialogic.VAR.set_variable("opcion_b", opciones[1] if opciones.size() > 1 else "")
		Dialogic.VAR.set_variable("opcion_c", opciones[2] if opciones.size() > 2 else "")
		Dialogic.VAR.set_variable("opcion_d", opciones[3] if opciones.size() > 3 else "")
		Dialogic.VAR.set_variable("respuesta_correcta", pregunta_actual["respuestaCorrecta"])
		Dialogic.start("preguntas_timeline")

func verificar_respuesta(opcion: String):
	if respuesta_recibida:
		return
	respuesta_recibida = true
	temporizador.stop()
	contador_en_ejecucion = false
	limpiar_contador()

	var correcta = Dialogic.VAR.get_variable("respuesta_correcta")
	var danio = pregunta_actual.get("costoEnergia", 5)
	
	# Calcular tiempo de respuesta
	var tiempo_limite = pregunta_actual.get("tiempoLimite", 30)
	var tiempo_respuesta = int(tiempo_limite - temporizador.time_left)
	
	# Mapear la opción seleccionada (a, b, c, d) al valor real
	var opciones = pregunta_actual["opciones"]
	var respuesta_dada = ""
	match opcion:
		"a":
			respuesta_dada = opciones[0] if opciones.size() > 0 else ""
		"b":
			respuesta_dada = opciones[1] if opciones.size() > 1 else ""
		"c":
			respuesta_dada = opciones[2] if opciones.size() > 2 else ""
		"d":
			respuesta_dada = opciones[3] if opciones.size() > 3 else ""
		_:
			push_error("Opción no válida: ", opcion)
	
	# Verificar si la respuesta es correcta
	var es_correcta = respuesta_dada == correcta
	
	# Actualizar estadísticas
	if es_correcta:
		GameManager.aciertos += 1
	else:
		GameManager.errores += 1
	
	# Enviar respuesta a la API
	enviar_respuesta_api(
		pregunta_actual["idPregunta"],
		respuesta_dada,
		es_correcta,
		tiempo_respuesta
	)
	
	await jugador.responder_pregunta()

	if es_correcta:
		await mago.aplaudir()
		mago.recibir_danio(danio)
	else:
		await jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not await chequear_fin_del_juego():
		await iniciar_turno_mago()

func _on_tiempo_agotado():
	if not respuesta_recibida:
		respuesta_recibida = true
		contador_en_ejecucion = false
		limpiar_contador()
		Dialogic.end_timeline()
		var danio = pregunta_actual.get("costoEnergia", 5)
		
		# Actualizar estadísticas
		GameManager.errores += 1
		
		# Enviar respuesta a la API indicando que no se respondió
		var tiempo_limite = pregunta_actual.get("tiempoLimite", 30)
		enviar_respuesta_api(
			pregunta_actual["idPregunta"],
			"",  # Respuesta vacía porque el tiempo se agotó
			false,
			tiempo_limite
		)
		
		await jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not await chequear_fin_del_juego():
		await iniciar_turno_mago()

### FIN DEL JUEGO ###

func chequear_fin_del_juego() -> bool:
	if jugador.vida_actual <= 0:
		jugador.perder_juego()
		SceneBridge.set_game_result("derrota")
		game_ended = true
		print("Setting game_ended to true (derrota)")
		# Guardar el tiempo total
		GameManager.tiempo_total = tiempo_partida
		await get_tree().create_timer(3.0).timeout
		print("Temporizador de 3 segundos finalizado, cambiando a escena resultados.tscn")
		get_tree().call_deferred("change_scene_to_file", "res://escenas/sc_final/resultados.tscn")
		return true
	elif mago.vida_actual <= 0:
		mago.aplaudir()
		jugador.bailar()
		SceneBridge.set_game_result("victoria")
		game_ended = true
		print("Setting game_ended to true (victoria)")
		# Guardar el tiempo total
		GameManager.tiempo_total = tiempo_partida
		await get_tree().create_timer(3.0).timeout
		print("Temporizador de 3 segundos finalizado, cambiando a escena resultados.tscn")
		get_tree().call_deferred("change_scene_to_file", "res://escenas/sc_final/resultados.tscn")
		return true
	return false

### VISUAL ###

func mostrar_turno(texto: String):
	if texto_turno:
		texto_turno.text = texto
		texto_turno.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_property(texto_turno, "modulate:a", 0.0, 2.0).set_delay(1.0)
		if get_tree().paused:
			tween.pause()

func iniciar_contador(tiempo: int) -> void:
	if contador_en_ejecucion:
		return
	contador_en_ejecucion = true
	contador_turno.text = "Tiempo restante: %d" % tiempo

func limpiar_contador():
	if contador_turno:
		contador_turno.text = ""
	contador_en_ejecucion = false

func _on_carta_usada(tipo: String, data: Variant) -> void:
	print("Se usó una carta de tipo:", tipo, "con data:", data)
	
	match tipo:
		"curacion":
			var cantidad = int(data.get("cantidad", 0))
			await jugador.curar_vida(cantidad)
		"dano_extra":
			pass
		_:
			print("Tipo de carta no reconocido:", tipo) 
