extends Control

# Referencias a los nodos
@onready var background = $rect_background  # TextureRect para el fondo (solo para verificar que existe)
@onready var personaje_rect = $rect_background/boy  # TextureRect para los personajes
@onready var btn_left = $rect_background/btn_left
@onready var btn_right = $rect_background/btn_right
@onready var btn_accept = $rect_background/btn_accept

# Lista de texturas (imágenes de los personajes)
var personajes = []
var current_index = 0  # Índice para el personaje actual

func _ready() -> void:
	# Cargar las imágenes de los personajes desde la carpeta
	personajes.append(load("res://assets/ui/seleccionar personaje/boy.png"))
	personajes.append(load("res://assets/ui/seleccionar personaje/girl.png"))

	# Asegurarse de que hay al menos 1 personaje
	if personajes.size() < 1:
		push_error("Necesitas al menos 1 personaje para la selección.")
		return

	# Verificar que los nodos existan
	if background == null:
		push_error("No se encontró el nodo 'Background'. Revisa el nombre o la ruta en la escena.")
	if personaje_rect == null:
		push_error("No se encontró el nodo 'PersonajeRect'. Revisa el nombre o la ruta en la escena.")
		return

	# Configurar la textura inicial del PersonajeRect
	update_personaje_texture()

	# Verificar que los botones existan antes de conectar señales
	if btn_left == null:
		push_error("No se encontró el nodo 'btn_left'. Revisa el nombre o la ruta en la escena.")
	else:
		btn_left.pressed.connect(_on_btn_left_pressed)

	if btn_right == null:
		push_error("No se encontró el nodo 'btn_right'. Revisa el nombre o la ruta en la escena.")
	else:
		btn_right.pressed.connect(_on_btn_right_pressed)

	if btn_accept == null:
		push_error("No se encontró el nodo 'btn_aceptar'. Revisa el nombre o la ruta en la escena.")
	else:
		btn_accept.pressed.connect(_on_btn_accept_pressed)

func update_personaje_texture() -> void:
	# Actualizar solo la textura del PersonajeRect
	personaje_rect.texture = personajes[current_index]

func _on_btn_left_pressed() -> void:
	# Cambiar el personaje hacia la izquierda
	current_index -= 1
	if current_index < 0:
		current_index = personajes.size() - 1  
	update_personaje_texture()

func _on_btn_right_pressed() -> void:
	# Cambiar el personaje hacia la derecha
	current_index = (current_index + 1) % personajes.size()
	update_personaje_texture()

func _on_btn_accept_pressed() -> void:
	# Guardar la selección y cambiar de escena
	print("Personaje seleccionado: ", current_index)
	get_tree().change_scene_to_file("res://Main.tscn")  # Usar change_scene_to_file en Godot 4
