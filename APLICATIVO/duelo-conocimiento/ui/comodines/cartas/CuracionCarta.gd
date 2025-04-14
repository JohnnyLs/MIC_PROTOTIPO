extends Node2D

@export var cantidad_curacion: int = 30
@onready var carta = $Carta
signal carta_usada
func _ready():
	carta.ingresar_valores_carta("Curación", "Recupera vida al jugador")
	carta.connect("carta_clickeada", Callable(self, "_al_clic_de_la_carta"))

func _al_clic_de_la_carta():
	print("Curación activada")
	emit_signal("carta_usada", "curacion", {"cantidad": cantidad_curacion})
	#carta.desactivar_carta()
