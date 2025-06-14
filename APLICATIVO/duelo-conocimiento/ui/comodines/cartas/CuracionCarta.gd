extends Node2D

@export var cantidad_curacion: int = 30
@onready var carta = $Carta
@onready var icono = $icono
@onready var imagen = $imagen

var ya_usada: bool = false  # Flag para prevenir múltiples usos

# Variables para el efecto hover de toda la carta
var color_original: Color = Color.WHITE
var escala_original: Vector2 = Vector2.ONE
var hover_tween: Tween

signal carta_usada

func _ready():
	carta.ingresar_valores_carta("Recuperar Energía", "+ 30 de energía (un solo uso)")
	carta.connect("carta_clickeada", Callable(self, "_al_clic_de_la_carta"))
	
	# Conectar los eventos de mouse desde aquí para manejar toda la carta
	var area = carta.get_node("SpriteBaseCarta/AreaClick")
	if area:
		area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
		area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
	# Guardar valores originales para la animación
	color_original = modulate
	escala_original = scale

func _on_mouse_entered():
	if ya_usada:
		return
	
	print("Mouse entró en CuracionCarta")
	
	# Cancelar cualquier animación previa
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	# Efecto dorado brillante para toda la carta
	var color_dorado = Color(1.2, 1.0, 0.3, 1.0)  # Dorado brillante
	hover_tween.tween_property(self, "modulate", color_dorado, 0.2)
	
	# Hacer toda la carta un poco más grande
	var escala_hover = escala_original * 1.1
	hover_tween.tween_property(self, "scale", escala_hover, 0.2)

func _on_mouse_exited():
	if ya_usada:
		return
	
	print("Mouse salió de CuracionCarta")
	
	# Cancelar cualquier animación previa
	if hover_tween:
		hover_tween.kill()
	
	hover_tween = create_tween()
	hover_tween.set_parallel(true)
	
	# Volver al color original
	hover_tween.tween_property(self, "modulate", color_original, 0.2)
	
	# Volver al tamaño original
	hover_tween.tween_property(self, "scale", escala_original, 0.2)

func _al_clic_de_la_carta():
	# Verificar si la carta ya fue usada
	if ya_usada:
		print("La carta de curación ya fue usada")
		return
	
	print("Curación activada")
	ya_usada = true  # Marcar como usada inmediatamente
	
	# Desactivar visualmente la carta para feedback inmediato
	desactivar_carta()
	
	# Emitir la señal
	emit_signal("carta_usada", "curacion", {"cantidad": cantidad_curacion})

func desactivar_carta():
	# Cancelar cualquier efecto hover activo
	if hover_tween:
		hover_tween.kill()
	
	# Cambiar el color para indicar que está desactivada (toda la carta)
	modulate = Color(0.5, 0.5, 0.5, 0.8)
	
	# Desactivar la detección de input en la carta hija
	carta.desactivar_carta()
