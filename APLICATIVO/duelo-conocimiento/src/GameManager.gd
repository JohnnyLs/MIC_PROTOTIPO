extends Node

var pregunta_actual
var jugador: Node = null
var mago: Node = null

var turno_actual := "mago"
var temporizador: Timer
var respuesta_recibida := false

func _ready():
	# Obtener referencias directamente desde el árbol de la escena actual
	var escena_actual = get_tree().get_current_scene()
	jugador = escena_actual.get_node("Jugador")
	mago = escena_actual.get_node("Mago")

	print("Jugador encontrado:", jugador != null)
	print("Mago encontrado:", mago != null)

	# Crear temporizador
	temporizador = Timer.new()
	temporizador.one_shot = true
	temporizador.timeout.connect(_on_tiempo_agotado)
	add_child(temporizador)

	iniciar_turno()

func iniciar_turno():
	if turno_actual == "mago":
		print("\n>>> Turno del mago")
		await get_tree().create_timer(3.0).timeout
		lanzar_pregunta()
		var tiempo_limite = pregunta_actual.get("tiempo_límite", 30)
		temporizador.start(tiempo_limite)
		respuesta_recibida = false
		turno_actual = "jugador"

func lanzar_pregunta():
	pregunta_actual = PreguntaManager.obtener_pregunta_aleatoria()
	if pregunta_actual:
		Dialogic.VAR.set_variable("pregunta_texto", pregunta_actual["pregunta"])
		Dialogic.VAR.set_variable("opcion_a", pregunta_actual["opciones"]["a"])
		Dialogic.VAR.set_variable("opcion_b", pregunta_actual["opciones"]["b"])
		Dialogic.VAR.set_variable("opcion_c", pregunta_actual["opciones"]["c"])
		Dialogic.VAR.set_variable("opcion_d", pregunta_actual["opciones"]["d"])
		Dialogic.VAR.set_variable("respuesta_correcta", pregunta_actual["respuesta_correcta"])
		Dialogic.start("preguntas_timeline")

func verificar_respuesta(opcion: String):
	if respuesta_recibida:
		return

	respuesta_recibida = true
	temporizador.stop()

	var correcta = Dialogic.VAR.get_variable("respuesta_correcta")
	var danio = pregunta_actual.get("coste_energía", 5)

	print("Jugador está asignado:", jugador != null)
	print("Mago está asignado:", mago != null)

	if opcion == correcta:
		print("Respuesta correcta. El mago recibe", danio)
		if mago:
			mago.recibir_danio(danio)
	else:
		print("Respuesta incorrecta. El jugador recibe", danio)
		if jugador:
			jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not chequear_fin_del_juego():
		turno_actual = "mago"
		iniciar_turno()

func _on_tiempo_agotado():
	if not respuesta_recibida:
		print("Tiempo agotado. El jugador recibe daño")
		respuesta_recibida = true
		var danio = pregunta_actual.get("coste_energía", 5)
		if jugador:
			jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not chequear_fin_del_juego():
		turno_actual = "mago"
		iniciar_turno()

func chequear_fin_del_juego() -> bool:
	if jugador.vida_actual <= 0:
		print("El jugador ha perdido.")
		Dialogic.start("derrota_timeline")
		return true
	elif mago.vida_actual <= 0:
		print("El jugador ha ganado.")
		Dialogic.start("victoria_timeline")
		return true
	return false
