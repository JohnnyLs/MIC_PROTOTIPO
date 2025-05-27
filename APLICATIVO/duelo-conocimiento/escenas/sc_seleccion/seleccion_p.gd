extends Control

# Referencias a los nodos
@onready var background = $rect_background  
@onready var personaje_rect = $rect_background/boy  
@onready var btn_left = $rect_background/btn_left
@onready var btn_right = $rect_background/btn_right
@onready var btn_accept = $rect_background/btn_accept
@onready var text_edit = $TextEdit
@onready var http_request = $HTTPRequest  # Nodo HTTPRequest agregado a la escena

# Lista de texturas (imágenes de los personajes)
var personajes = []
var current_index = 0  

func _ready() -> void:
	# Cargar las imágenes de los personajes desde la carpeta
	personajes.append(load("res://assets/ui/seleccionar personaje/boy.png"))
	personajes.append(load("res://assets/ui/seleccionar personaje/girl.png"))

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

	# Conectar señal para manejar respuesta de la API
	http_request.request_completed.connect(_on_request_completed)

func update_personaje_texture() -> void:
	personaje_rect.texture = personajes[current_index]

func _on_btn_left_pressed() -> void:
	current_index -= 1
	if current_index < 0:
		current_index = personajes.size() - 1  
	update_personaje_texture()

func _on_btn_right_pressed() -> void:
	current_index = (current_index + 1) % personajes.size()
	update_personaje_texture()

func _on_btn_accept_pressed() -> void:
	var nombre = text_edit.text.strip_edges()
	
	if nombre.is_empty():
		print("Por favor, ingresa tu nombre")
		return

	# Determinar nombre del personaje (puedes personalizar estos nombres)
	var personaje = "Personaje" + str(current_index + 1)

	# Crear JSON
	var json_data = {
		"nombrePerfil": nombre,
		"personaje": personaje
	}

	var json_str = JSON.stringify(json_data)
	var headers = ["Content-Type: application/json"]

	# Enviar solicitud POST
	var error = http_request.request(
		"http://localhost:8082/api/partidas",
		headers,
		HTTPClient.METHOD_POST,
		json_str
	)

	if error != OK:
		print("Error al realizar la solicitud HTTP:", error)
	else:
		print("Solicitud enviada, esperando respuesta...")

	# Guardar en GameManager (puedes mover esto dentro del _on_request_completed si quieres esperar respuesta)
	GameManager.personaje_index = current_index
	GameManager.nombre_jugador = nombre 

func _on_request_completed(result, response_code, headers, body):
	print("Respuesta del servidor:", response_code)
	print("Contenido:", body.get_string_from_utf8())

	# Cambiar de escena después de recibir la respuesta (puedes agregar validación del código si quieres)
	GameManager.cambiar_escena("res://Main.tscn")
