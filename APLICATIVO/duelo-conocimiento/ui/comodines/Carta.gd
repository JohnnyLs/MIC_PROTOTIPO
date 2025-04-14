@tool
class_name Carta extends Node2D

@export var nombre_carta: String = "nombre"
@export var descripcion_carta: String = "descripcion"
@export var icono_carta: Sprite2D
@export var imagen_carta: Sprite2D

@onready var desc_lbl = $InfoCarta/DescripcionCarta
@onready var nombre_lbl = $InfoCarta/NombreCarta/NombreCartaTexto


signal carta_clickeada

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		emit_signal("carta_clickeada")

# Called when the node enters the scene tree for the first time.
func _ready():
	ingresar_valores_carta(nombre_carta,descripcion_carta)
	var area = $SpriteBaseCarta/AreaClick
	if area:
		area.connect("input_event", Callable(self, "_on_input_event"))
	

func ingresar_valores_carta(_nombre: String,_descripcion: String):
	nombre_carta = _nombre
	descripcion_carta = _descripcion
	_update_graphics()
	
	
func _update_graphics():
	if nombre_lbl.get_text() != nombre_carta:
		nombre_lbl.set_text(nombre_carta)
	if desc_lbl.get_text() != descripcion_carta:
		desc_lbl.set_text(descripcion_carta)

func desactivar_carta():
	modulate = Color(0.5, 0.5, 0.5, 0.5) # La vuelve gris
	set_process_input(false)            # Ya no responde al clic

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_update_graphics()
