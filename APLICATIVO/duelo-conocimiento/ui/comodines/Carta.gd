@tool
class_name Carta extends Node2D

@export var nombre_carta: String = "nombre"
@export var descripcion_carta: String = "descripcion"
@export var icono_carta: Sprite2D
@export var imagen_carta: Sprite2D

@onready var desc_lbl = $InfoCarta/DescripcionCarta
@onready var nombre_lbl = $InfoCarta/NombreCarta/NombreCartaTexto

signal carta_clickeada

# Variables para el efecto hover (ahora manejadas por el padre)
var color_original: Color = Color.WHITE
var escala_original: Vector2 = Vector2.ONE
var esta_desactivada: bool = false

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not esta_desactivada:
			emit_signal("carta_clickeada")

func _ready():
	# Guardar valores originales
	color_original = modulate
	escala_original = scale
	
	ingresar_valores_carta(nombre_carta, descripcion_carta)
	
	var area = $SpriteBaseCarta/AreaClick
	if area:
		area.connect("input_event", Callable(self, "_on_input_event"))
		# Los eventos de mouse ahora se manejan desde CuracionCarta
		# No conectamos mouse_entered y mouse_exited aquí

func ingresar_valores_carta(_nombre: String, _descripcion: String):
	nombre_carta = _nombre
	descripcion_carta = _descripcion
	update_graphics()

func update_graphics():
	if nombre_lbl and nombre_lbl.get_text() != nombre_carta:
		nombre_lbl.set_text(nombre_carta)
	if desc_lbl and desc_lbl.get_text() != descripcion_carta:
		desc_lbl.set_text(descripcion_carta)

func desactivar_carta():
	esta_desactivada = true
	
	# Cambiar el color para indicar que está desactivada
	modulate = Color(0.5, 0.5, 0.5, 0.8)
	
	# Desactivar la detección de input
	var area = $SpriteBaseCarta/AreaClick
	if area:
		area.set_deferred("monitoring", false)
		area.set_deferred("monitorable", false)
	
	# Opcional: agregar una pequeña animación de "click"
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _process(delta):
	update_graphics()
