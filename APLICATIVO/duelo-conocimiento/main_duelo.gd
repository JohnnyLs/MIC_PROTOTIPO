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

# Referencia a la escena del menú de opciones
var opciones_scene = preload("res://escenas/sc_menu_opciones/menu_opciones.tscn")
var opciones_instance = null

# Referencia a los nodos de Dialogic (para ocultar/mostrar sus interfaces)
var dialogic_nodes: Array[Node] = []  # Lista de nodos Dialogic para ocultar/mostrar
var dialogic_timeline_active: bool = false  # Track if a Dialogic timeline is active
var game_ended: bool = false  # Track if the game has ended to trigger scene change

func _ready():
	SceneBridge.set_main_duelo(self)
	if not is_inside_tree():
		push_error("Este nodo no está en el árbol de escenas al iniciar. No se puede continuar.")
		return

	# Obtener referencias a los nodos en la escena actual
	jugador = $Jugador
	mago = $Mago
	
	# Asegurarse de que las bases de los nodos 3D sean ortonormales
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
	
	# Crear y configurar el temporizador
	temporizador = Timer.new()
	temporizador.one_shot = true
	temporizador.timeout.connect(_on_tiempo_agotado)
	add_child(temporizador)
	
	# Conectar señales de Dialogic para rastrear el estado del timeline
	Dialogic.timeline_started.connect(_on_dialogic_timeline_started)
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)
	
	await iniciar_turno_mago()

func _process(delta: float) -> void:
	# Actualizar el contador visual basado en el tiempo restante del temporizador
	if contador_en_ejecucion and temporizador and not temporizador.is_stopped():
		var tiempo_restante = ceil(temporizador.time_left)
		contador_turno.text = "Tiempo restante: %d" % tiempo_restante

# Señales de Dialogic para rastrear el estado del timeline
func _on_dialogic_timeline_started():
	dialogic_timeline_active = true
	print("Dialogic timeline started")

func _on_dialogic_timeline_ended():
	dialogic_timeline_active = false
	print("Dialogic timeline ended")
	print("game_ended:", game_ended)
	if game_ended:
		print("Cambiando a escena resultados.tscn")
		get_tree().change_scene_to_file("res://escenas/sc_final/resultados.tscn")

# Detectar la tecla Esc para abrir/cerrar el menú de opciones
func _input(event: InputEvent) -> void:
	if not is_inside_tree():
		print("El nodo no está en el árbol de escenas al procesar la entrada.")
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("Presionado Esc en Main.tscn. Escena actual:", get_tree().current_scene.name if get_tree() else "No hay SceneTree")
		if opciones_instance == null:  # Si el menú no está abierto
			var scene_tree = get_tree()
			if scene_tree == null:
				push_error("No se pudo acceder al SceneTree. El nodo probablemente fue eliminado del árbol de escenas.")
				return
			# Pausar el juego de forma diferida
			call_deferred("_pause_and_open_menu")
		else:
			# Si el menú está abierto, no consumimos el evento para que menu_opciones.tscn lo maneje
			pass

func _pause_and_open_menu() -> void:
	var scene_tree = get_tree()
	if scene_tree == null:
		push_error("No se pudo acceder al SceneTree al pausar el juego.")
		return
	scene_tree.paused = true
	# Pausar el temporizador mientras el juego está pausado
	if temporizador and not temporizador.is_stopped():
		temporizador.paused = true
	# Pausar Dialogic y ocultar sus interfaces
	if dialogic_timeline_active:  # Usar la variable de rastreo
		Dialogic.paused = true  # Pausa Dialogic
		# Buscar todos los nodos de Dialogic en la raíz del Viewport
		var root = get_tree().root
		for child in root.get_children():
			if child.name.begins_with("Dialogic"):
				# Imprimir todos los hijos para depuración
				print("Dialogic node children:", child.get_children())
				# Buscar todos los hijos que sean capas de Dialogic
				for subchild in child.get_children():
					if subchild is CanvasLayer:  # DialogicLayoutLayer hereda de CanvasLayer
						dialogic_nodes.append(subchild)
						subchild.visible = false
						print("Dialogic UI node found and hidden:", subchild.name)
				break
	opciones_instance = opciones_scene.instantiate()
	# Asegurarse de que el menú esté en una capa superior
	if opciones_instance is CanvasLayer:
		opciones_instance.layer = 10  # Capa alta para estar por encima de Dialogic
		add_child(opciones_instance)
	else:
		var canvas_layer = CanvasLayer.new()
		canvas_layer.layer = 10
		canvas_layer.add_child(opciones_instance)
		add_child(canvas_layer)
	opciones_instance.connect("tree_exited", Callable(self, "_on_opciones_closed"))

# Función para cerrar el menú de opciones y reanudar el juego
func _on_opciones_closed() -> void:
	opciones_instance = null
	var scene_tree = get_tree()
	if scene_tree == null:
		push_error("No se pudo acceder al SceneTree al reanudar el juego.")
		return
	scene_tree.paused = false
	# Reanudar el temporizador cuando el juego se reanuda
	if temporizador and temporizador.paused:
		temporizador.paused = false
	# Reanudar Dialogic y mostrar sus interfaces
	if dialogic_timeline_active:  # Usar la variable de rastreo
		Dialogic.paused = false  # Reanuda Dialogic
		for node in dialogic_nodes:
			node.visible = true
			print("Dialogic UI node shown again:", node.name)
		dialogic_nodes.clear()
	# Reanudar el tween de mostrar_turno si está pausado
	if texto_turno and texto_turno.modulate.a > 0:
		var tween = create_tween()
		tween.tween_property(texto_turno, "modulate:a", 0.0, 2.0).set_delay(1.0)

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

	var tiempo_limite = pregunta_actual.get("tiempo_límite", 30)
	temporizador.start(tiempo_limite)
	iniciar_contador(tiempo_limite)
	# No necesitamos 'await' aquí porque no estamos esperando que el contador termine

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
	contador_en_ejecucion = false  # Detener el contador visual
	limpiar_contador()

	var correcta = Dialogic.VAR.get_variable("respuesta_correcta")
	var danio = pregunta_actual.get("coste_energía", 5)
	
	await jugador.responder_pregunta()

	if opcion == correcta:
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
		contador_en_ejecucion = false  # Detener el contador visual
		limpiar_contador()
		Dialogic.end_timeline()
		var danio = pregunta_actual.get("coste_energía", 5)
		await jugador.recibir_danio(danio)

	await get_tree().create_timer(1.5).timeout
	if not await chequear_fin_del_juego():
		await iniciar_turno_mago()

### FIN DEL JUEGO ###

func chequear_fin_del_juego() -> bool:
	if jugador.vida_actual <= 0:
		# Iniciar la animación de perderpartida (no esperamos)
		jugador.perder_juego()  # No bloquea ejecución
		# Iniciar un temporizador de 5 segundos para cambiar de escena
		SceneBridge.set_game_result("derrota")
		game_ended = true
		print("Setting game_ended to true (derrota)")
		await get_tree().create_timer(3.0).timeout
		print("Temporizador de 3 segundos finalizado, cambiando a escena resultados.tscn")
		get_tree().change_scene_to_file("res://escenas/sc_final/resultados.tscn")
		return true
	elif mago.vida_actual <= 0:
		# Iniciar las animaciones de victoria (no esperamos)
		mago.aplaudir()
		jugador.bailar()
		# Iniciar un temporizador de 5 segundos para cambiar de escena
		SceneBridge.set_game_result("victoria")
		game_ended = true
		print("Setting game_ended to true (victoria)")
		await get_tree().create_timer(3.0).timeout
		print("Temporizador de 3 segundos finalizado, cambiando a escena resultados.tscn")
		get_tree().change_scene_to_file("res://escenas/sc_final/resultados.tscn")
		return true
	return false

### VISUAL ###

func mostrar_turno(texto: String):
	if texto_turno:
		texto_turno.text = texto
		texto_turno.modulate.a = 1.0
		var tween := create_tween()
		tween.tween_property(texto_turno, "modulate:a", 0.0, 2.0).set_delay(1.0)
		# Pausar el tween si el juego está pausado
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
