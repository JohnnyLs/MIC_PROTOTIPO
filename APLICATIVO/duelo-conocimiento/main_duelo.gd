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

func _ready():
	SceneBridge.set_main_duelo(self)
	# Obtener referencias a los nodos en la escena actual
	jugador = $Jugador
	mago = $Mago
	
	texto_turno = $UIDuelo/ContenedorInterfazDuelo/VBoxContainer/Turno_texto
	contador_turno = $UIDuelo/ContenedorInterfazDuelo/VBoxContainer/Contador_turno
	
	var mano_comodines = $ManoComodines
	if mano_comodines:
		mano_comodines.conectar_cartas()
		
	print("¡Cargó Main.tscn correctamente!")
	print("Jugador visible:", $Jugador.is_visible_in_tree())
	print("Mago visible:", $Mago.is_visible_in_tree())
	
	# Crear y configurar el temporizador
	temporizador = Timer.new()
	temporizador.one_shot = true
	temporizador.timeout.connect(_on_tiempo_agotado)
	add_child(temporizador)
	
	iniciar_turno_mago()


### TURNOS ###

func iniciar_turno_mago():
	turno_actual = "mago"
	mostrar_turno("Turno de Conty!")
	await get_tree().create_timer(3.0).timeout
	mago.lanzar_pregunta_animada()
	lanzar_pregunta()
	await get_tree().process_frame
	iniciar_turno_jugador()

func iniciar_turno_jugador():
	turno_actual = "jugador"
	mostrar_turno("Ahora es tu turno!")
	respuesta_recibida = false

	var tiempo_limite = pregunta_actual.get("tiempo_límite", 30)
	temporizador.start(tiempo_limite)
	await iniciar_contador(tiempo_limite)


### PREGUNTAS ###

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
	limpiar_contador()

	var correcta = Dialogic.VAR.get_variable("respuesta_correcta")
	var danio = pregunta_actual.get("coste_energía", 5)
	
	jugador.responder_pregunta()

	if opcion == correcta:
		mago.aplaudir()
		mago.recibir_danio(danio)
	else:
		jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not chequear_fin_del_juego():
		iniciar_turno_mago()

func _on_tiempo_agotado():
	if not respuesta_recibida:
		respuesta_recibida = true
		limpiar_contador()
		Dialogic.end_timeline()
		var danio = pregunta_actual.get("coste_energía", 5)
		jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not chequear_fin_del_juego():
		iniciar_turno_mago()


### FIN DEL JUEGO ###

func chequear_fin_del_juego() -> bool:
	if jugador.vida_actual <= 0:
		jugador.perder_juego()
		Dialogic.start("derrota_timeline")
		return true
	elif mago.vida_actual <= 0:
		mago.aplaudir()
		jugador.bailar()
		Dialogic.start("victoria_timeline")
		return true
	return false


### VISUAL ###

func mostrar_turno(texto: String):
	if texto_turno:
		texto_turno.text = texto
		texto_turno.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_property(texto_turno, "modulate:a", 0.0, 2.0).set_delay(1.0)

func iniciar_contador(tiempo: int) -> void:
	if contador_en_ejecucion:
		return
	contador_en_ejecucion = true

	for segundos in range(tiempo, -1, -1):
		if respuesta_recibida:
			break
		if contador_turno:
			contador_turno.text = "Tiempo restante: %s" % segundos
		await get_tree().create_timer(1.0).timeout

	contador_en_ejecucion = false

func limpiar_contador():
	if contador_turno:
		contador_turno.text = ""

func _on_carta_usada(tipo: String, data: Variant) -> void:
	print("Se usó una carta de tipo:", tipo, "con data:", data)
	
	match tipo:
		"curacion":
			var cantidad = int(data.get("cantidad", 0))
			jugador.curar_vida(cantidad)
		"dano_extra":
			pass
		_:
			print("Tipo de carta no reconocido:", tipo)
