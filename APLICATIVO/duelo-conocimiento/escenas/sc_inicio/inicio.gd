extends Node

@onready var lbl_titulo = $LblTitulo  # Asegúrate que este es el Label de título
var full_text = "MATH QUIZ" 
var letter_speed = 0.2  # Tiempo entre letras (más rápido que "Cargando...")
var wave_amplitude = 5.0
var wave_frequency = 2.5
var letter_spacing = 5.0
var reset_delay = 1.2
var time_elapsed = 0.0
var base_position: Vector2
var letters = []
var char_index = 0


func _on_button_pressed() -> void:
	AudioManager.reproducir_clic()
	GameManager.cambiar_escena("res://escenas/sc_seleccion/seleccion_p.tscn")

func _ready():
	base_position = lbl_titulo.position
	lbl_titulo.visible = false  # Ocultamos el original
	AudioManager.reproducir_musica("res://sonidos/Whispers of the Forgotten Quest.mp3")
	var offset_x = 0.0
	for i in range(full_text.length()):
		var letter_label = Label.new()
		letter_label.text = full_text[i]

		# Copiar estilo visual
		letter_label.add_theme_font_override("font", lbl_titulo.get_theme_font("font"))
		letter_label.add_theme_font_size_override("font_size", lbl_titulo.get_theme_font_size("font_size"))
		letter_label.add_theme_color_override("font_color", lbl_titulo.get_theme_color("font_color"))
		letter_label.add_theme_color_override("font_outline_color", Color("#412e0b"))
		letter_label.add_theme_constant_override("outline_size", 50)

		# Posicionamiento inicial
		letter_label.position = Vector2(base_position.x + offset_x, base_position.y)
		add_child(letter_label)
		letters.append({"label": letter_label, "delay": i * letter_speed})
		letter_label.hide()

		offset_x += letter_spacing + letter_label.size.x

func _process(delta):
	time_elapsed += delta

	if char_index < letters.size() and time_elapsed >= letters[char_index].delay:
		letters[char_index].label.show()
		char_index += 1

	for letter in letters:
		var offset = Vector2(0, sin(time_elapsed * wave_frequency + letters.find(letter)) * wave_amplitude)
		letter.label.position = Vector2(letter.label.position.x, base_position.y + offset.y)
