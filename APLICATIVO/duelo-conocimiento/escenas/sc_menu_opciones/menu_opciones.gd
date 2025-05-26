extends Control

# Referencias a los nodos
@onready var btn_continuar = $ContenedorOpciones/btn_continuar
@onready var btn_config = $ContenedorOpciones/btn_config
@onready var btn_salir = $ContenedorOpciones/btn_salir

# Referencia a la escena de sonido
var sonido_scene = preload("res://escenas/sc_sonido/sonido.tscn")
var sonido_instance = null
var just_closed_sonido: bool = false  # Flag to track if Sonido.tscn was just closed

func _ready() -> void:
	# Set process mode to always to ensure the menu works while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Verificar que los nodos existan
	if btn_continuar == null:
		push_error("No se encontró el nodo 'btn_continuar'. Revisa el nombre o la ruta en la escena.")
		return
	if btn_config == null:
		push_error("No se encontró el nodo 'btn_config'. Revisa el nombre o la ruta en la escena.")
		return
	if btn_salir == null:
		push_error("No se encontró el nodo 'btn_salir'. Revisa el nombre o la ruta en la escena.")
		return

	# Set process mode for buttons to ensure they can process input
	btn_continuar.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_config.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_salir.process_mode = Node.PROCESS_MODE_ALWAYS

	# Configurar focus_mode para permitir clics
	btn_continuar.focus_mode = Control.FOCUS_CLICK
	btn_config.focus_mode = Control.FOCUS_CLICK
	btn_salir.focus_mode = Control.FOCUS_CLICK

	# Desactivar el rectángulo blanco visualmente usando un tema
	var theme = Theme.new()
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	btn_continuar.theme = theme
	btn_config.theme = theme
	btn_salir.theme = theme

	# Asegurarse de que los botones puedan recibir eventos de ratón
	btn_continuar.mouse_filter = Control.MOUSE_FILTER_PASS
	btn_config.mouse_filter = Control.MOUSE_FILTER_PASS
	btn_salir.mouse_filter = Control.MOUSE_FILTER_PASS

	# Conectar las señales de los botones
	btn_continuar.pressed.connect(_on_btn_continuar_pressed)
	btn_config.pressed.connect(_on_btn_config_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)

	# Conectar señales para el efecto hover en los botones
	btn_continuar.mouse_entered.connect(_on_btn_continuar_mouse_entered)
	btn_continuar.mouse_exited.connect(_on_btn_continuar_mouse_exited)
	btn_config.mouse_entered.connect(_on_btn_config_mouse_entered)
	btn_config.mouse_exited.connect(_on_btn_config_mouse_exited)
	btn_salir.mouse_entered.connect(_on_btn_salir_mouse_entered)
	btn_salir.mouse_exited.connect(_on_btn_salir_mouse_exited)

# Detectar la tecla Esc para cerrar el menú de opciones
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("Esc pressed in menu_opciones.tscn. Sonido instance:", sonido_instance, " Just closed sonido:", just_closed_sonido)
		if sonido_instance != null:
			# Si la escena de sonido está abierta, ciérrala
			sonido_instance.queue_free()
		elif not just_closed_sonido:
			# Si no hay escena de sonido abierta y no acabamos de cerrar Sonido.tscn, cierra el menú de opciones
			print("Closing menu_opciones.tscn")
			queue_free()
		# Reset the flag after processing the event
		just_closed_sonido = false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("Mouse click detected in menu_opciones.tscn at position:", event.position)
		# Debug: Check which button (if any) is under the mouse
		var mouse_pos = event.position
		if btn_continuar.get_global_rect().has_point(mouse_pos):
			print("Click is over btn_continuar")
		if btn_config.get_global_rect().has_point(mouse_pos):
			print("Click is over btn_config")
		if btn_salir.get_global_rect().has_point(mouse_pos):
			print("Click is over btn_salir")
# Funciones para los botones
func _on_btn_continuar_pressed() -> void:
	print("btn_continuar pressed in menu_opciones.tscn")
	queue_free()  # Cierra el menú y regresa al juego

func _on_btn_config_pressed() -> void:
	print("btn_config pressed in menu_opciones.tscn")
	if sonido_instance == null:  # Evitar abrir múltiples instancias
		sonido_instance = sonido_scene.instantiate()
		add_child(sonido_instance)
		# Conectar una señal para limpiar la referencia cuando la escena de sonido se cierre
		sonido_instance.connect("tree_exited", Callable(self, "_on_sonido_closed"))

func _on_btn_salir_pressed() -> void:
	print("btn_salir pressed in menu_opciones.tscn")
	# Regresa al menú principal (Inicio.tscn) y despausa el juego
	get_tree().paused = false
	get_tree().change_scene_to_file("res://escenas/Inicio.tscn")

# Limpiar la referencia cuando la escena de sonido se cierre
func _on_sonido_closed() -> void:
	print("Sonido.tscn closed, returning to menu_opciones.tscn")
	sonido_instance = null
	just_closed_sonido = true  # Set the flag to indicate Sonido.tscn was just closed

# Efectos hover para los botones
func _on_btn_continuar_mouse_entered() -> void:
	btn_continuar.modulate = Color(1, 1, 0, 1)  # Amarillo brillante

func _on_btn_continuar_mouse_exited() -> void:
	btn_continuar.modulate = Color(1, 1, 1, 1)  # Blanco (color original)

func _on_btn_config_mouse_entered() -> void:
	btn_config.modulate = Color(1, 1, 0, 1)  # Amarillo brillante

func _on_btn_config_mouse_exited() -> void:
	btn_config.modulate = Color(1, 1, 1, 1)  # Blanco (color original)

func _on_btn_salir_mouse_entered() -> void:
	btn_salir.modulate = Color(1, 1, 0, 1)  # Amarillo brillante

func _on_btn_salir_mouse_exited() -> void:
	btn_salir.modulate = Color(1, 1, 1, 1)  # Blanco (color original)
