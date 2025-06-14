extends Control

# Referencias a los nodos
@onready var background = $rect_background  
@onready var personaje_rect = $rect_background/boy  
@onready var btn_left = $rect_background/btn_left
@onready var btn_right = $rect_background/btn_right
@onready var btn_accept = $rect_background/btn_accept
@onready var text_edit = $TextEdit
@onready var http_request = $HTTPRequest 

# Lista de texturas (imágenes de los personajes)
var personajes = []

# Expresión regular para validar solo letras (incluyendo ñ y tildes) y espacios
var regex = RegEx.new()
var current_index = 0 

func _ready() -> void:
	# Compilar la expresión regular para letras, ñ, tildes y espacios
	regex.compile("^[a-zA-ZáéíóúÁÉÍÓÚñÑ ]*$")

	# Cargar las imágenes de los personajes desde la carpeta
	personajes.append(load("res://assets/ui/seleccionar personaje/boy.png")) # Index 0: hombre
	personajes.append(load("res://assets/ui/seleccionar personaje/girl.png")) # Index 1: mujer

	if personajes.size() < 1:
		push_error("Necesitas al menos 1 personaje para la selección.")
		return

	if background == null:
		push_error("No se encontró el nodo 'Background'.")
	if personaje_rect == null:
		push_error("No se encontró el nodo 'PersonajeRect'.")
		return

	update_personaje_texture()
	text_edit.placeholder_text = "Ingresa tu nombre"

	if btn_left != null:
		btn_left.pressed.connect(_on_btn_left_pressed)

	if btn_right != null:
		btn_right.pressed.connect(_on_btn_right_pressed)

	if btn_accept != null:
		btn_accept.pressed.connect(_on_btn_accept_pressed)

	# Conectar señal para validar texto en tiempo real
	if text_edit != null:
		text_edit.text_changed.connect(_on_text_edit_text_changed)

	# Conectar señal para manejar respuesta de la API
	http_request.request_completed.connect(_on_request_completed)

func _on_text_edit_text_changed() -> void:
	var text = text_edit.text
	var cursor_pos = text_edit.get_caret_column()
	
	# Imprimir el texto crudo para depuración
	print("DEBUG: Texto ingresado: '", text, "'")

	# Validar el texto completo con la expresión regular
	var valid_text = text
	if not regex.search(text):
		# Si el texto no es válido, filtrar caracteres no permitidos
		valid_text = ""
		for char in text:
			if regex.search(str(char)) or char == " ":
				valid_text += char
		print("DEBUG: Texto después de filtrar: '", valid_text, "'")

	# Limitar a 22 caracteres
	if valid_text.length() > 22:
		valid_text = valid_text.substr(0, 22)
		print("DEBUG: Texto después de límite: '", valid_text, "'")

	# Capitalizar la primera letra de cada palabra, preservando espacios
	var has_trailing_space = text.ends_with(" ")
	valid_text = _capitalize_words(valid_text)
	if has_trailing_space and not valid_text.ends_with(" "):
		valid_text += " "
	print("DEBUG: Texto después de capitalizar: '", valid_text, "'")

	# Si el texto cambió, actualizar el TextEdit
	if text != valid_text:
		var old_pos = cursor_pos
		text_edit.text = valid_text
		# Ajustar la posición del cursor
		if old_pos <= valid_text.length():
			text_edit.set_caret_column(old_pos)
		else:
			text_edit.set_caret_column(valid_text.length())

func _capitalize_words(text: String) -> String:
	# Dividir por espacios, preservando palabras no vacías
	var words = text.split(" ", false)
	var capitalized_words = []
	
	for word in words:
		if word.length() > 0:
			# Capitalizar la primera letra y mantener el resto en minúscula
			var capitalized = word.substr(0, 1).to_upper() + word.substr(1).to_lower()
			capitalized_words.append(capitalized)
	
	# Unir las palabras con un espacio
	return " ".join(capitalized_words)

func update_personaje_texture() -> void:
	personaje_rect.texture = personajes[current_index]
	print("Personaje mostrado: index =", current_index, ", género =", "hombre" if current_index == 0 else "mujer")

func _on_btn_left_pressed() -> void:
	AudioManager.reproducir_sonido("clic2")
	current_index -= 1
	if current_index < 0:
		current_index = personajes.size() - 1  
	update_personaje_texture()

func _on_btn_right_pressed() -> void:
	AudioManager.reproducir_sonido("clic2")
	current_index = (current_index + 1) % personajes.size()
	update_personaje_texture()

func _on_btn_accept_pressed() -> void:
	AudioManager.reproducir_clic()
	var nombre = text_edit.text.strip_edges()
	
	if nombre.is_empty():
		print("Por favor, ingresa tu nombre")
		return
	
	# Validar que el nombre contenga solo letras, ñ, tildes y espacios
	if not regex.search(nombre):
		print("El nombre solo puede contener letras, ñ, tildes y espacios")
		return

	# Establecer personaje_index en GameManager antes de obtener el género
	GameManager.personaje_index = current_index
	var personaje = GameManager.get_genero_personaje()
	print("DEBUG: Enviando al API - nombre:", nombre, ", personaje:", personaje, ", index:", current_index)

	# Crear JSON para la API de partidas
	var json_data = {
		"nombrePerfil": nombre,
		"personaje": personaje
	}

	var json_str = JSON.stringify(json_data)
	var headers = ["Content-Type: application/json"]

	# Enviar solicitud POST usando la URL base desde GameManager
	var error = http_request.request(
		GameManager.API_BASE_URL + "partidas",
		headers,
		HTTPClient.METHOD_POST,
		json_str
	)

	if error != OK:
		print("Error al realizar la solicitud HTTP:", error)
	else:
		print("Solicitud enviada, JSON:", json_str)
		
		# Guardar datos en GameManager antes de la respuesta
		GameManager.personaje_index = current_index
		GameManager.nombre_jugador = nombre
		GameManager.personaje = personaje

func _on_request_completed(result, response_code, headers, body):
	print("Respuesta del servidor:", response_code)
	var body_str = body.get_string_from_utf8()
	print("Contenido de la respuesta:", body_str)

	# Parsear la respuesta para obtener el idPartida
	var json = JSON.new()
	var error = json.parse(body_str)
	if error != OK:
		push_error("Error al parsear JSON de la respuesta de la API de partidas: ", error)
		return
	
	var data = json.get_data()
	if response_code == 200 and data is Dictionary and data.has("idPartida"):
		GameManager.id_partida = data["idPartida"]
		print("idPartida guardado en GameManager:", GameManager.id_partida)
	else:
		push_error("Respuesta de la API de partidas inválida o sin idPartida: ", data)
		return
	
	# Cambiar a la escena del duelo
	GameManager.cambiar_escena("res://Main.tscn")
