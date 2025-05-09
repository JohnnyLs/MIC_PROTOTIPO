extends CharacterBody3D

@onready var barra_vida = $UIJugador/ContenedorInterfaz/VContenedorInterfaz/Fila1/VidaBar  # Asegúrate que esta ruta sea correcta
@onready var modelo_contenedor = $ModeloContenedor  # El nuevo contenedor Node3D

var vida_maxima := 100
var vida_actual := 100


# Recibe el género desde el menú principal
var genero := "hombre"  # Esto lo actualizas desde el GameManager o el menú

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	print("Vida actual del jugador tras recibir daño:", vida_actual)
	barra_vida.value = vida_actual

func curar_vida(cantidad):
	vida_actual = clamp(vida_actual + cantidad, 0, vida_maxima)
	print("Vida actual del jugador tras curarse:", vida_actual)
	barra_vida.value = vida_actual

func _ready():
	barra_vida.value = vida_actual  # Inicializa barra al comienzo
	cargar_modelo()

func _input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	#print("→ Input event detectado")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("¡Haz hecho clic sobre el jugador!")
		recibir_danio(10)
		
func cargar_modelo():
	var ruta_modelo := ""
	match genero:
		"hombre":
			ruta_modelo = "res://personajes/jugador/jugador_modelo.glb"
		"mujer":
			ruta_modelo = "res://modelos/jugadora_mujer.glb"
	
	var escena_modelo = load(ruta_modelo)
	if escena_modelo:
		var instancia = escena_modelo.instantiate()
		modelo_contenedor.add_child(instancia)
		instancia.position = Vector3.ZERO # Alinea el modelo al centro del contenedor
		print("Tipo de instancia cargada:", instancia)

	else:
		print("No se pudo cargar el modelo:", ruta_modelo)
