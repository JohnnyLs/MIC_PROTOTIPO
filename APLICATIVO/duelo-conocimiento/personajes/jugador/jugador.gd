extends CharacterBody3D

signal animation_finished_signal(animation_name)

@onready var barra_vida = $UIJugador/VidaBar
@onready var modelo_contenedor = $ModeloContenedor
@onready var imagen_jugador = $UIJugador/Imagen
@onready var vfx_impact = $vfx_impact
@onready var vfx_smoke = $vfx_smoke
var vida_maxima := 100
var vida_actual := 100
var genero := "hombre"  # Se asigna desde GameManager
var nombre_jugador := ""  # Se asigna desde GameManager
var anim_player : AnimationPlayer = null
var anim_actual := ""

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	vfx_smoke.activar_puff_humo()
	print("Vida actual del jugador tras recibir daño:", vida_actual)
	barra_vida.value = vida_actual
	AudioManager.reproducir_sonido("fallo")
	var main_duelo = SceneBridge.get_main_duelo()
	if main_duelo:
		main_duelo.actualizar_visibilidad_carta()
	await reproducir_animacion("perdernergia")

func curar_vida(cantidad):
	vida_actual = clamp(vida_actual + cantidad, 0, vida_maxima)
	print("Vida actual del jugador tras curarse:", vida_actual)
	barra_vida.value = vida_actual
	AudioManager.reproducir_sonido("curarse")
	await reproducir_animacion("curarse")
	
func obtener_vida_actual() -> int:
	return vida_actual

func _ready():
	# Obtener datos del GameManager
	genero = GameManager.get_genero_personaje()
	nombre_jugador = GameManager.nombre_jugador
	
	print("=== JUGADOR DEBUG ===")
	print("Género:", genero)
	print("Nombre:", nombre_jugador)
	print("====================")
	
	barra_vida.value = vida_actual
	cargar_modelo()
	configurar_nombre_ui()
	cargar_textura_ui()

func configurar_nombre_ui():
	# Ruta corregida para el RichTextLabel
	var label_nombre = $UIJugador/NombreJugador
	
	if label_nombre:
		# Para RichTextLabel, usamos .text (no .bbcode_text a menos que tengas BBCode)
		label_nombre.text = nombre_jugador
		print("Nombre configurado en UI:", nombre_jugador)
	else:
		print("ERROR: No se encontró el nodo NombreJugador en la ruta:")
		print("$UIJugador/ContenedorInterfaz/VContenedorInterfaz/Fila1/NombreJugador")
		# Debug: Listar los nodos disponibles
		var fila1 = $UIJugador/ContenedorInterfaz/VContenedorInterfaz/Fila1
		if fila1:
			print("Nodos disponibles en Fila1:")
			for child in fila1.get_children():
				print("- ", child.name, " (", child.get_class(), ")")

func _input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("¡Haz hecho clic sobre el jugador!")
		recibir_danio(10)

func cargar_modelo():
	var ruta_modelo := ""
	match genero:
		"hombre":
			
			ruta_modelo = "res://personajes/jugador/ninio.glb"
		"mujer":
			ruta_modelo = "res://personajes/jugadora/ninia.glb"
	
	print("Cargando modelo:", ruta_modelo)
	
	var escena_modelo = load(ruta_modelo)
	if escena_modelo:
		var instancia = escena_modelo.instantiate()
		modelo_contenedor.add_child(instancia)
		instancia.position = Vector3.ZERO
		
		anim_player = instancia.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.animation_finished.connect(_on_animacion_finalizada)
			if anim_player.has_animation("reposo"):
				await reproducir_animacion("reposo")
			else:
				print("No se encontró la animación 'reposo'.")
		else:
			print("No se encontró AnimationPlayer.")
		
		print("Modelo cargado exitosamente")
	else:
		print("ERROR: No se pudo cargar el modelo:", ruta_modelo)

func reproducir_animacion(nombre: String):
	if anim_player and anim_player.has_animation(nombre):
		if anim_actual != nombre:
			anim_actual = nombre
			anim_player.play(nombre)
			print("Reproduciendo animación:", nombre)
			await anim_player.animation_finished
			animation_finished_signal.emit(nombre)
			
func cargar_textura_ui():
	var ruta_imagen := ""
	match genero:
		"hombre":
			ruta_imagen = "res://assets/ui/personajes/jugador-img.png"
		"mujer":
			ruta_imagen = "res://assets/ui/personajes/jugadora-img.png"
	
	if not ResourceLoader.exists(ruta_imagen):
		print("La ruta de imagen no existe:", ruta_imagen)
		return
	
	var textura := load(ruta_imagen)
	if textura:
		imagen_jugador.texture = textura
		print("Textura asignada correctamente:", ruta_imagen)
	else:
		print("Falló la carga de textura:", ruta_imagen)



func _process(_delta):
	if anim_actual == "reposo":
		# Reasegurar que la animación de reposo se mantenga en loop
		if not anim_player.is_playing():
			reproducir_animacion("reposo")

func _on_animacion_finalizada(nombre):
	# Si terminó una animación distinta a 'reposo', volvemos a reposo
	if nombre != "reposo":
		await reproducir_animacion("reposo")
		
func responder_pregunta():
	AudioManager.reproducir_sonido("responder-pregunta")
	if vfx_impact:
		vfx_impact.activar_efectos_con_duracion(1.5)
	await reproducir_animacion("responder")
	
func perder_juego():
	await reproducir_animacion("perderpartida")
	
func frustracion():
	await reproducir_animacion("frustracion")
	
func bailar():
	await reproducir_animacion("bailar")
