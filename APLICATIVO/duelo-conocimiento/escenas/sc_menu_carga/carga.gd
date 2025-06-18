extends Node

@onready var lbl_cargando = $LblCargando  # Label original, usado como referencia para estilo
var full_text = "Cargando..."  # Texto completo a mostrar
var letter_speed = 0.2  # Tiempo entre letras (en segundos)
var wave_amplitude = 10.0  # Amplitud del movimiento de onda
var wave_frequency = 2.0  # Frecuencia del movimiento de onda
var letter_spacing = 10.0  # Espaciado entre letras (en píxeles)
var reset_delay = 0.5  # Tiempo de espera antes de reiniciar (en segundos)
var time_elapsed = 0.0  # Tiempo transcurrido
var base_position: Vector2  # Posición base del grupo de letras
var letters = []  # Almacena los Labels de cada letra
var char_index = 0  # Índice de la letra actual

func _ready():
	# Guarda la posición original del Label
	base_position = lbl_cargando.position
	# Oculta el Label original, ya que usaremos Labels individuales
	lbl_cargando.visible = false
	# Crea un Label por cada letra
	var offset_x = 0.0
	for i in range(full_text.length()):
		var letter_label = Label.new()
		letter_label.text = full_text[i]
		# Copia el estilo del Label original
		letter_label.add_theme_font_override("font", lbl_cargando.get_theme_font("font"))
		letter_label.add_theme_font_size_override("font_size", lbl_cargando.get_theme_font_size("font_size"))
		letter_label.add_theme_color_override("font_color", lbl_cargando.get_theme_color("font_color"))
		# Añade el color de contorno (#412e0b) y tamaño de contorno (30)
		letter_label.add_theme_color_override("font_outline_color", Color("#412e0b"))
		letter_label.add_theme_constant_override("outline_size", 30)  # Grosor del contorno
		letter_label.position = Vector2(base_position.x + offset_x, base_position.y)
		add_child(letter_label)
		letters.append({"label": letter_label, "delay": i * letter_speed})
		letter_label.hide()  # Oculta inicialmente
		offset_x += letter_spacing + letter_label.size.x  # Ajusta el espaciado

func _process(delta):
	# Actualiza el tiempo transcurrido
	time_elapsed += delta

	# Muestra las letras con retraso
	if char_index < letters.size() and time_elapsed >= letters[char_index].delay:
		letters[char_index].label.show()
		char_index += 1

	# Reinicia el texto cuando se completa
	if char_index >= letters.size() and time_elapsed >= letters[-1].delay + reset_delay:
		for letter in letters:
			letter.label.hide()
		char_index = 0
		time_elapsed = 0.0  # Reinicia el temporizador para el nuevo ciclo

	# Aplica el efecto de onda a todas las letras
	for letter in letters:
		var offset = Vector2(0, sin(time_elapsed * wave_frequency) * wave_amplitude)
		letter.label.position = Vector2(letter.label.position.x, base_position.y + offset.y)
