# vfx_impact.gd - Versión simplificada
# Script para adjuntar al nodo vfx_impact

extends Node

# Referencias a los nodos hijos de efectos
@onready var flash = $flash
@onready var flare = $flare
@onready var shockwave = $Shockwave
@onready var sparks = $sparks

# Función simple para activar todos los efectos
func activar_efectos():
	print("Activando efectos VFX")
	
	# Si los efectos ya están configurados para emitir automáticamente
	# solo necesitas activar el emitting
	if flash:
		flash.emitting = true
	if flare:
		flare.emitting = true
	if shockwave:
		shockwave.emitting = true
	if sparks:
		sparks.emitting = true

# Función para desactivar efectos
func desactivar_efectos():
	if flash:
		flash.emitting = false
	if flare:
		flare.emitting = false
	if shockwave:
		shockwave.emitting = false
	if sparks:
		sparks.emitting = false

# Función con duración automática
func activar_efectos_con_duracion(duracion: float = 2.0):
	activar_efectos()
	
	# Auto-desactivar después del tiempo especificado
	await get_tree().create_timer(duracion).timeout
	desactivar_efectos()

# Función para activar efectos específicos
func activar_efecto(nombre_efecto: String):
	match nombre_efecto:
		"flash":
			if flash: flash.emitting = true
		"flare":
			if flare: flare.emitting = true
		"shockwave":
			if shockwave: shockwave.emitting = true
		"sparks":
			if sparks: sparks.emitting = true
		"all":
			activar_efectos()

# Ejecuta los efectos varias veces mientras dure la animación
func reproducir_efectos_durante_animacion(duracion_total: float, intervalo: float = 0.5):
	call_deferred("_loop_efectos_durante_animacion", duracion_total, intervalo)

# Función interna que ejecuta el bucle de efectos
func _loop_efectos_durante_animacion(duracion_total: float, intervalo: float):
	var tiempo_transcurrido = 0.0
	
	while tiempo_transcurrido < duracion_total:
		activar_efectos()
		await get_tree().create_timer(0.3).timeout  # Tiempo que permanece encendido
		desactivar_efectos()

		await get_tree().create_timer(intervalo).timeout  # Espera antes de volver a activar
		tiempo_transcurrido += intervalo + 0.3  # Total transcurrido
