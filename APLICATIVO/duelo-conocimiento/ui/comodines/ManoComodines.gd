# ManoComodines.gd
extends Control

func _ready():
	print("ManoComodines está listo")
	await get_tree().process_frame
	conectar_cartas()

func _on_carta_usada(tipo: String, data: Variant, carta_emisora: Node = null):
	print("ManoComodines recibió carta usada:", tipo, data)
	
	# Usar SceneBridge para obtener la referencia al main_duelo
	var main_duelo = SceneBridge.get_main_duelo()
	if main_duelo and main_duelo.has_method("_on_carta_usada"):
		print("Llamando a _on_carta_usada en main_duelo")
		main_duelo._on_carta_usada(tipo, data)
		
		# Eliminar la carta después de usarla con una pequeña animación
		if carta_emisora:
			eliminar_carta_con_animacion(carta_emisora)
	else:
		print("Error: No se pudo encontrar main_duelo o el método _on_carta_usada")
		print("main_duelo existe:", main_duelo != null)
		if main_duelo:
			print("main_duelo tiene método:", main_duelo.has_method("_on_carta_usada"))

func eliminar_carta_con_animacion(carta: Node):
	print("Eliminando carta:", carta.name)
	
	# Crear una animación de desaparición
	var tween = create_tween()
	tween.set_parallel(true)  # Permite múltiples animaciones simultáneas
	
	# Animación de escala (se encoge)
	tween.tween_property(carta, "scale", Vector2.ZERO, 0.5)
	
	# Animación de rotación
	tween.tween_property(carta, "rotation", carta.rotation + PI, 0.5)
	
	# Animación de transparencia
	tween.tween_property(carta, "modulate:a", 0.0, 0.5)
	
	# Eliminar la carta cuando termine la animación
	await tween.finished
	carta.queue_free()
	print("Carta eliminada:", carta.name)

func conectar_cartas():
	print("Conectando cartas manualmente. Hijos:", get_child_count())
	for carta in get_children():
		if carta.has_signal("carta_usada"):
			if not carta.is_connected("carta_usada", Callable(self, "_on_carta_usada_real")):
				print("Conectando carta:", carta.name)
				carta.connect("carta_usada", Callable(self, "_on_carta_usada_real").bind(carta))

# Nuevo método real con .bind para recibir la carta emisora como parámetro
func _on_carta_usada_real(tipo: String, data: Variant, carta_emisora: Node):
	_on_carta_usada(tipo, data, carta_emisora)
