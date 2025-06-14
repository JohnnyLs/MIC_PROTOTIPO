extends CharacterBody3D

signal animation_finished_signal(animation_name)

@onready var barra_vida = $UIMago/ContenedorInterfaz/VContenedorInterfaz/Fila1/VidaBar
@onready var modelo := $magoModelo
@onready var anim_player : AnimationPlayer = $magoModelo/AnimationPlayer
@onready var vfx_impact = $vfx_impact
@onready var vfx_smoke = $vfx_smoke
var anim_actual := ""
var vida_maxima := 100
var vida_actual := 100

func _ready():
	barra_vida.value = vida_actual
	if anim_player:
		anim_player.animation_finished.connect(_on_animacion_finalizada)
		if anim_player.has_animation("reposo"):
			await reproducir_animacion("reposo")
		else:
			print("No se encontró animación 'reposo'.")
	else:
		print("No se encontró AnimationPlayer")

func recibir_danio(cantidad):
	vida_actual = clamp(vida_actual - cantidad, 0, vida_maxima)
	vfx_smoke.activar_puff_humo()
	barra_vida.value = vida_actual
	AudioManager.reproducir_sonido("perder-energia")
	print("Vida actual del mago tras recibir daño:", vida_actual)
	# await reproducir_animacion("recibir_danio")  # Descomentado si tienes esta animación

func reproducir_animacion(nombre: String):
	if anim_player and anim_player.has_animation(nombre):
		if anim_actual != nombre:
			anim_actual = nombre
			anim_player.play(nombre)
			print("Mago reproduce animación:", nombre)
			await anim_player.animation_finished
			animation_finished_signal.emit(nombre)

func _process(_delta):
	if anim_actual == "reposo" and anim_player and not anim_player.is_playing():
		await reproducir_animacion("reposo")

func _on_animacion_finalizada(nombre):
	if nombre != "reposo":
		await reproducir_animacion("reposo")

func lanzar_pregunta_animada():
	AudioManager.reproducir_sonido("lanzar_pregunta")
	vfx_impact.reproducir_efectos_durante_animacion(2.5, 0.6)
	await reproducir_animacion("lanzarpregunta")
	
	
func animar():
	await reproducir_animacion("animar")
	
func aplaudir():
	await reproducir_animacion("aplaudir")
	
func finjuego():
	await reproducir_animacion("aplaudir")
