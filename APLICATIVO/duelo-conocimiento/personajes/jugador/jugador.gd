extends CharacterBody3D

@onready var barra_vida = $UIJugador/ContenedorInterfaz/VContenedorInterfaz/Fila1/VidaBar  # Asegúrate que esta ruta sea correcta

var vida_maxima := 100
var vida_actual := 100

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	print("Vida actual del jugador tras recibir daño:", vida_actual)
	barra_vida.value = vida_actual

func _ready():
	barra_vida.value = vida_actual  # Inicializa barra al comienzo

func _input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	#print("→ Input event detectado")
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("¡Haz hecho clic sobre el jugador!")
		recibir_danio(10)
