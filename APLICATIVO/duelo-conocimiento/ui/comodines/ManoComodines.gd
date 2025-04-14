extends Control

func _ready():
	print("ManoComodines está listo")
	await get_tree().process_frame
	conectar_cartas()


func _on_carta_usada(tipo: String, data: Variant):
	print("ManoComodines recibió carta usada:", tipo, data)
	print("GameManager existe:", GameManager)
	print("Tiene método _on_carta_usada:", GameManager.has_method("_on_carta_usada"))
	GameManager._on_carta_usada(tipo, data)

		
func conectar_cartas():
	print("Conectando cartas manualmente. Hijos:", get_child_count())

	for carta in get_children():
		if carta.has_signal("carta_usada"):
			print("Conectando carta:", carta.name)
			carta.connect("carta_usada", Callable(self, "_on_carta_usada"))
