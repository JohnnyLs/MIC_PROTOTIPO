extends Node

@onready var sonido_clic = $clic
@onready var musica_fondo = $musica_inicio
@onready var responder_pregunta = $"responder-pregunta"

var musica_actual = ""
var volumen_musica: float = -10.0  # Volumen en decibelios (-80.0 a 0.0)
var fade_time := 1.5  # Duración del fade in/out
var _transicionando := false

func _ready():
	musica_fondo.volume_db = volumen_musica

func reproducir_sonido(nombre_nodo: String):
	var nodo_sonido = get_node_or_null(nombre_nodo)
	if nodo_sonido and nodo_sonido is AudioStreamPlayer:
		nodo_sonido.play()
	else:
		print("Nodo de sonido no encontrado o no es un AudioStreamPlayer: ", nombre_nodo)

func reproducir_clic():
	sonido_clic.play()

func reproducir_musica(ruta_audio: String):
	if musica_actual != ruta_audio and not _transicionando:
		_transicionando = true

		await _fade_out()

		var nueva_musica = load(ruta_audio)
		musica_fondo.stream = nueva_musica
		musica_fondo.play()
		musica_actual = ruta_audio

		musica_fondo.volume_db = volumen_musica  # Aplica volumen deseado

		await _fade_in()
		_transicionando = false

func set_volumen_musica(db: float) -> void:
	volumen_musica = clamp(db, -80.0, 0.0)  
	if musica_fondo and musica_fondo.playing:
		musica_fondo.volume_db = volumen_musica

func parar_musica():
	musica_fondo.stop()
	musica_actual = ""

# --- Fades privados ---
func _fade_out():
	var original_vol = musica_fondo.volume_db
	for i in range(10):
		musica_fondo.volume_db = lerp(original_vol, -80.0, i / 10.0)
		await get_tree().create_timer(fade_time / 10.0).timeout
	musica_fondo.stop()

func _fade_in():
	musica_fondo.volume_db = -80.0
	for i in range(10):
		musica_fondo.volume_db = lerp(-80.0, volumen_musica, i / 10.0)
		await get_tree().create_timer(fade_time / 10.0).timeout
