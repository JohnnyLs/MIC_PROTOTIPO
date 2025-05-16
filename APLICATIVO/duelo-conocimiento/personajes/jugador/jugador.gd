extends CharacterBody3D

@onready var barra_vida = $UIJugador/ContenedorInterfaz/VContenedorInterfaz/Fila1/VidaBar
@onready var modelo_contenedor = $ModeloContenedor

var vida_maxima := 100
var vida_actual := 100

var genero := "mujer"  # Se asigna desde fuera del script
var anim_player : AnimationPlayer = null
var anim_actual := ""

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	print("Vida actual del jugador tras recibir daño:", vida_actual)
	barra_vida.value = vida_actual
	reproducir_animacion("perdernergia")

func curar_vida(cantidad):
	vida_actual = clamp(vida_actual + cantidad, 0, vida_maxima)
	print("Vida actual del jugador tras curarse:", vida_actual)
	barra_vida.value = vida_actual
	reproducir_animacion("curarse")

func _ready():
	barra_vida.value = vida_actual
	cargar_modelo()

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
	
	var escena_modelo = load(ruta_modelo)
	if escena_modelo:
		var instancia = escena_modelo.instantiate()
		modelo_contenedor.add_child(instancia)
		instancia.position = Vector3.ZERO
		
		anim_player = instancia.get_node_or_null("AnimationPlayer")
		if anim_player:
			anim_player.animation_finished.connect(_on_animacion_finalizada)
			if anim_player.has_animation("reposo"):
				reproducir_animacion("reposo")
			else:
				print("No se encontró la animación 'reposo'.")
		else:
			print("No se encontró AnimationPlayer.")
	else:
		print("No se pudo cargar el modelo:", ruta_modelo)

func reproducir_animacion(nombre: String):
	if anim_player and anim_player.has_animation(nombre):
		if anim_actual != nombre:
			anim_actual = nombre
			anim_player.play(nombre)
			print("Reproduciendo animación:", nombre)

func _process(_delta):
	if anim_actual == "reposo":
		# Reasegurar que la animación de reposo se mantenga en loop
		if not anim_player.is_playing():
			reproducir_animacion("reposo")

func _on_animacion_finalizada(nombre):
	# Si terminó una animación distinta a 'reposo', volvemos a reposo
	if nombre != "reposo":
		reproducir_animacion("reposo")
		
func responder_pregunta():
	reproducir_animacion("responder")
	
func perder_juego():
	reproducir_animacion("perderpartida")
	
func frustracion():
	reproducir_animacion("frustracion")
	
func bailar():
	reproducir_animacion("bailar")
