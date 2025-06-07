extends Node

@onready var sonido_clic = $clic
@onready var musica_fondo = $musica_inicio
@onready var responder_pregunta = $"responder-pregunta"

var musica_actual = ""
var fade_time := 1.5  # Duración en segundos del fade out/in
var _transicionando := false


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
		# Empieza fade out
		await _fade_out()
		
		# Cambia la música
		var nueva_musica = load(ruta_audio)
		musica_fondo.stream = nueva_musica
		musica_fondo.play()
		musica_actual = ruta_audio
		
		# Empieza fade in
		await _fade_in()
		_transicionando = false

func parar_musica():
	musica_fondo.stop()
	musica_actual = ""

# --- Funciones privadas para fade ---

func _fade_out():
	var original_vol = musica_fondo.volume_db
	for i in range(10):
		musica_fondo.volume_db = lerp(original_vol, -80.0, i / 10.0)
		await get_tree().create_timer(fade_time / 10.0).timeout
	musica_fondo.stop()

func _fade_in():
	musica_fondo.volume_db = -80.0  # Inicia bajo
	for i in range(10):
		musica_fondo.volume_db = lerp(-80.0, 0.0, i / 10.0)
		await get_tree().create_timer(fade_time / 10.0).timeout
