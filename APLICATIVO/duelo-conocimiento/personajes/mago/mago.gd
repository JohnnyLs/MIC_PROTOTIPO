extends CharacterBody3D

@onready var barra_vida = $UIMago/ContenedorInterfaz/VContenedorInterfaz/Fila1/VidaBar
@onready var modelo := $magoModelo
@onready var anim_player : AnimationPlayer = $magoModelo/AnimationPlayer

var anim_actual := ""
var vida_maxima := 100
var vida_actual := 100

func _ready():
	barra_vida.value = vida_actual
	if anim_player:
		anim_player.animation_finished.connect(_on_animacion_finalizada)
		if anim_player.has_animation("reposo"):
			reproducir_animacion("reposo")
		else:
			print("No se encontró animación 'reposo'.")
	else:
		print("No se encontró AnimationPlayer")

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	barra_vida.value = vida_actual
	print("Vida actual del mago tras recibir daño:", vida_actual)
	#reproducir_animacion("recibir_danio")


func reproducir_animacion(nombre: String):
	if anim_player and anim_player.has_animation(nombre):
		if anim_actual != nombre:
			anim_actual = nombre
			anim_player.play(nombre)
			print("Mago reproduce animación:", nombre)

func _process(_delta):
	if anim_actual == "reposo" and anim_player and not anim_player.is_playing():
		reproducir_animacion("reposo")

func _on_animacion_finalizada(nombre):
	if nombre != "reposo":
		reproducir_animacion("reposo")

func lanzar_pregunta_animada():
	reproducir_animacion("lanzarpregunta")
	
func animar():
	reproducir_animacion("animar")
	
func aplaudir():
	reproducir_animacion("aplaudir")
	
func finjuego():
	reproducir_animacion("aplaudir")
