# vfx_smoke.gd - Script para efectos de humo
# Script para adjuntar al nodo vfx_smoke

extends Node

# Referencias a los nodos hijos de efectos de humo
@onready var smoke = $smoke
@onready var destello2 = $destello2  # Si tienes un destello secundario

# Función simple para activar todos los efectos de humo
func activar_efectos():
	print("Activando efectos de humo VFX")
	
	# Activar emisión de partículas de humo
	if smoke:
		smoke.emitting = true
	if destello2:
		destello2.emitting = true

# Función para desactivar efectos
func desactivar_efectos():
	if smoke:
		smoke.emitting = false
	if destello2:
		destello2.emitting = false

# Función con duración automática
func activar_efectos_con_duracion(duracion: float = 3.0):
	activar_efectos()
	
	# Auto-desactivar después del tiempo especificado
	await get_tree().create_timer(duracion).timeout
	desactivar_efectos()

# Función para activar efectos específicos
func activar_efecto(nombre_efecto: String):
	match nombre_efecto:
		"smoke":
			if smoke: smoke.emitting = true
		"destello2":
			if destello2: destello2.emitting = true
		"all":
			activar_efectos()

# Función para humo continuo (útil para efectos prolongados)
func activar_humo_continuo():
	if smoke:
		smoke.emitting = true
		# Opcional: ajustar propiedades para humo continuo
		# smoke.amount = 50  # Más partículas por segundo
		# smoke.lifetime = 5.0  # Mayor duración de partículas

# Función para detener humo continuo gradualmente
func detener_humo_gradual(tiempo_fade: float = 2.0):
	if smoke:
		# Reducir gradualmente la emisión
		var tween = create_tween()
		var cantidad_inicial = smoke.amount if smoke.has_method("get_amount") else 30
		
		# Fade out de la cantidad de partículas
		if smoke.has_method("set_amount"):
			tween.tween_method(func(val): smoke.amount = val, cantidad_inicial, 0, tiempo_fade)
		
		await tween.finished
		smoke.emitting = false

# Ejecuta los efectos de humo de forma intermitente
func reproducir_efectos_durante_animacion(duracion_total: float, intervalo: float = 1.0):
	call_deferred("_loop_efectos_durante_animacion", duracion_total, intervalo)

# Función interna que ejecuta el bucle de efectos
func _loop_efectos_durante_animacion(duracion_total: float, intervalo: float):
	var tiempo_transcurrido = 0.0
	
	while tiempo_transcurrido < duracion_total:
		activar_efectos()
		await get_tree().create_timer(0.5).timeout  # Tiempo que permanece encendido
		desactivar_efectos()
		await get_tree().create_timer(intervalo).timeout  # Espera antes de volver a activar
		tiempo_transcurrido += intervalo + 0.5  # Total transcurrido

# Función específica para efectos de humo tipo puff (ráfaga corta)
func activar_puff_humo():
	if smoke:
		smoke.emitting = true
		# Emitir por un tiempo corto y luego detener
		await get_tree().create_timer(0.3).timeout
		smoke.emitting = false

# Función para ajustar intensidad del humo
func ajustar_intensidad_humo(intensidad: float):
	if smoke and smoke.has_method("set_amount"):
		smoke.amount = int(intensidad * 30)  # Base de 30 partículas por segundo
