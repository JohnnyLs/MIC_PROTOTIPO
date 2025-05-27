extends Control

# Referencias a los botones
@onready var btn_volver_jugar = $btn_volver_jugar  # Ajusta el nombre del nodo según tu escena
@onready var btn_menu_principal = $btn_menu_principal  # Ajusta el nombre del nodo según tu escena

func _ready():
	# Conectar las señales de los botones
	if btn_volver_jugar:
		btn_volver_jugar.pressed.connect(_on_btn_volver_jugar_pressed)
	else:
		push_error("Nodo BtnVolverJugar no encontrado. Verifica el nombre del nodo en la escena.")

	if btn_menu_principal:
		btn_menu_principal.pressed.connect(_on_btn_menu_principal_pressed)
	else:
		push_error("Nodo BtnMenuPrincipal no encontrado. Verifica el nombre del nodo en la escena.")


func _on_btn_volver_jugar_pressed():
	# Resetear el estado del juego si es necesario
	SceneBridge.set_game_result("")  # Limpiar el resultado anterior
	# Cargar la escena de la arena del duelo
	var error = get_tree().change_scene_to_file("res://Main.tscn")
	if error != OK:
		push_error("Error al cargar Main.tscn: " + str(error))

func _on_btn_menu_principal_pressed():
	# Resetear el estado del juego si es necesario
	SceneBridge.set_game_result("")  # Limpiar el resultado anterior
	# Cargar la escena del menú principal
	var error = get_tree().change_scene_to_file("res://escenas/sc_inicio/Inicio.tscn")
	if error != OK:
		push_error("Error al cargar Inicio.tscn: " + str(error))
