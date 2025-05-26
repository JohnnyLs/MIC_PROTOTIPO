extends Control

# Referencias a los nodos
@onready var slider_musica = $ContenedorSonido/SliderMusica
@onready var slider_sonido = $ContenedorSonido/SliderSonido
@onready var btn_regresar = $ContenedorSonido/btn_regresar

func _ready() -> void:
	# Set process mode to always to ensure the menu works while the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Verificar que los nodos existan
	if slider_musica == null:
		push_error("No se encontró el nodo 'SliderMusica'. Revisa el nombre o la ruta en la escena.")
		return
	if slider_sonido == null:
		push_error("No se encontró el nodo 'SliderSonido'. Revisa el nombre o la ruta en la escena.")
		return
	if btn_regresar == null:
		push_error("No se encontró el nodo 'btn_regresar'. Revisa el nombre o la ruta en la escena.")
		return

	# Set process mode for interactive elements
	slider_musica.process_mode = Node.PROCESS_MODE_ALWAYS
	slider_sonido.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_regresar.process_mode = Node.PROCESS_MODE_ALWAYS

	# Asegurarse de que el botón esté habilitado
	btn_regresar.disabled = false

	# Configurar focus_mode para permitir clics
	slider_musica.focus_mode = Control.FOCUS_CLICK
	slider_sonido.focus_mode = Control.FOCUS_CLICK
	btn_regresar.focus_mode = Control.FOCUS_CLICK

	# Desactivar el rectángulo blanco visualmente usando un tema
	var theme = Theme.new()
	theme.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	theme.set_stylebox("focus", "HSlider", StyleBoxEmpty.new())
	slider_musica.theme = theme
	slider_sonido.theme = theme
	btn_regresar.theme = theme

	# Asegurarse de que los elementos puedan recibir eventos de ratón
	slider_musica.mouse_filter = Control.MOUSE_FILTER_PASS
	slider_sonido.mouse_filter = Control.MOUSE_FILTER_PASS
	btn_regresar.mouse_filter = Control.MOUSE_FILTER_PASS

	# Conectar las señales de los sliders
	slider_musica.value_changed.connect(_on_slider_musica_changed)
	slider_sonido.value_changed.connect(_on_slider_sonido_changed)

	# Conectar las señales del botón regresar
	btn_regresar.pressed.connect(_on_btn_regresar_pressed)
	btn_regresar.mouse_entered.connect(_on_btn_regresar_mouse_entered)
	btn_regresar.mouse_exited.connect(_on_btn_regresar_mouse_exited)

	# Establecer los valores iniciales de los sliders
	slider_musica.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	slider_sonido.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")))

# Detectar la tecla Esc para cerrar la escena de sonido
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		print("Esc pressed in Sonido.tscn")
		queue_free()  # Cierra la escena y regresa a Opciones.tscn
		# Consumir el evento para evitar propagación
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = event.position
		print("Mouse click detected in Sonido.tscn at position:", mouse_pos)
		if slider_musica.get_global_rect().has_point(mouse_pos):
			print("Click is over SliderMusica")
		if slider_sonido.get_global_rect().has_point(mouse_pos):
			print("Click is over SliderSonido")
		if btn_regresar.get_global_rect().has_point(mouse_pos):
			print("Click is over btn_regresar")

# Funciones para los sliders de volumen
func _on_slider_musica_changed(value: float) -> void:
	print("SliderMusica changed to value:", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), value < 0.01)

func _on_slider_sonido_changed(value: float) -> void:
	print("SliderSonido changed to value:", value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(value))
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"), value < 0.01)

# Funciones para el botón regresar
func _on_btn_regresar_pressed() -> void:
	print("btn_regresar pressed in Sonido.tscn")
	queue_free()  # Cierra la escena y regresa a Opciones.tscn

func _on_btn_regresar_mouse_entered() -> void:
	print("Mouse entered btn_regresar")
	btn_regresar.modulate = Color(1, 1, 0, 1)  # Amarillo brillante

func _on_btn_regresar_mouse_exited() -> void:
	print("Mouse exited btn_regresar")
	btn_regresar.modulate = Color(1, 1, 1, 1)  # Blanco (color original)
