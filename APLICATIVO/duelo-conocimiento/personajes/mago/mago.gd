extends CharacterBody3D

@onready var barra_vida = $UIMago/ContenedorInterfaz/VContenedorInterfaz/Fila1/VidaBar

var vida_maxima := 100
var vida_actual := 100

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	print("Vida actual del mago tras recibir daño:", vida_actual)
	barra_vida.value = vida_actual

func _ready():
	barra_vida.value = vida_actual
