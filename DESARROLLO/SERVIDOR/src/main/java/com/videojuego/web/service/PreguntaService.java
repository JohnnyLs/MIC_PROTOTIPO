package com.videojuego.web.service;

import com.videojuego.web.dto.PreguntaDTO;
import com.videojuego.web.model.Pregunta;
import com.videojuego.web.repository.PreguntaRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PreguntaService {

    private static final Logger logger = LoggerFactory.getLogger(PreguntaService.class);

    @Autowired
    private PreguntaRepository preguntaRepository;

    // Crear una pregunta
    @Transactional
    public PreguntaDTO crearPregunta(PreguntaDTO request) {
        logger.info("Creando nueva pregunta: {}", request.getTextoPregunta());

        Pregunta pregunta = new Pregunta();
        pregunta.setTextoPregunta(request.getTextoPregunta());
        pregunta.setOpciones(request.getOpciones());
        pregunta.setRespuestaCorrecta(request.getRespuestaCorrecta());
        pregunta.setDificultad(request.getDificultad());
        pregunta.setTiempoLimite(request.getTiempoLimite());
        pregunta.setCategoria(request.getCategoria());
        pregunta.setCostoEnergia(request.getCostoEnergia());
        pregunta.setEstado(request.getEstado() != null ? request.getEstado() : "activo");

        Pregunta savedPregunta = preguntaRepository.save(pregunta);
        logger.info("Pregunta creada con id: {}", savedPregunta.getIdPregunta());

        return mapToDTO(savedPregunta);
    }

    // Obtener todas las preguntas
    @Transactional(readOnly = true)
    public List<PreguntaDTO> obtenerTodasLasPreguntas() {
        logger.info("Obteniendo todas las preguntas");

        List<Pregunta> preguntas = preguntaRepository.findAll();
        return preguntas.stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    // Obtener una pregunta por ID
    @Transactional(readOnly = true)
    public Pregunta findById(Integer id) {
        logger.info("Buscando pregunta con id: {}", id);

        return preguntaRepository.findById(id)
                .orElseThrow(() -> {
                    logger.warn("Pregunta no encontrada con id: {}", id);
                    return new RuntimeException("Pregunta no encontrada con id: " + id);
                });
    }

    // Actualizar una pregunta
    @Transactional
    public PreguntaDTO actualizarPregunta(Integer id, PreguntaDTO request) {
        logger.info("Actualizando pregunta con id: {}", id);

        Pregunta pregunta = findById(id);

        pregunta.setTextoPregunta(request.getTextoPregunta());
        pregunta.setOpciones(request.getOpciones());
        pregunta.setRespuestaCorrecta(request.getRespuestaCorrecta());
        pregunta.setDificultad(request.getDificultad());
        pregunta.setTiempoLimite(request.getTiempoLimite());
        pregunta.setCategoria(request.getCategoria());
        pregunta.setCostoEnergia(request.getCostoEnergia());
        pregunta.setEstado(request.getEstado());

        Pregunta updatedPregunta = preguntaRepository.save(pregunta);
        logger.info("Pregunta actualizada con id: {}", updatedPregunta.getIdPregunta());

        return mapToDTO(updatedPregunta);
    }

    // Eliminar una pregunta
    @Transactional
    public void eliminarPregunta(Integer id) {
        logger.info("Eliminando pregunta con id: {}", id);

        Pregunta pregunta = findById(id);

        preguntaRepository.delete(pregunta);
        logger.info("Pregunta eliminada con id: {}", id);
    }

    // Obtener preguntas aleatorias (restaurado y adaptado para el estado 'activo')
    @Transactional(readOnly = true)
    public List<PreguntaDTO> obtenerPreguntasAleatorias(Integer cantidad) {
        logger.info("Obteniendo {} preguntas aleatorias", cantidad);

        // Obtener todas las preguntas activas
        List<Pregunta> preguntasActivas = preguntaRepository.findAll().stream()
                .filter(pregunta -> "activo".equals(pregunta.getEstado()))
                .collect(Collectors.toList());

        // Mezclar las preguntas para obtener un orden aleatorio
        Collections.shuffle(preguntasActivas);

        // Limitar la cantidad de preguntas devueltas
        List<Pregunta> preguntasSeleccionadas = preguntasActivas.stream()
                .limit(cantidad)
                .collect(Collectors.toList());

        logger.info("Se encontraron {} preguntas activas, devolviendo {}", preguntasActivas.size(), preguntasSeleccionadas.size());
        return preguntasSeleccionadas.stream().map(this::mapToDTO).collect(Collectors.toList());
    }

    // Método adicional para el controlador
    @Transactional(readOnly = true)
    public PreguntaDTO obtenerPreguntaPorId(Integer id) {
        Pregunta pregunta = findById(id);
        return mapToDTO(pregunta);
    }

    // Método auxiliar para mapear Pregunta a PreguntaDTO
    private PreguntaDTO mapToDTO(Pregunta pregunta) {
        PreguntaDTO dto = new PreguntaDTO();
        dto.setIdPregunta(pregunta.getIdPregunta());
        dto.setTextoPregunta(pregunta.getTextoPregunta());
        dto.setOpciones(pregunta.getOpciones());
        dto.setRespuestaCorrecta(pregunta.getRespuestaCorrecta());
        dto.setDificultad(pregunta.getDificultad());
        dto.setTiempoLimite(pregunta.getTiempoLimite());
        dto.setCategoria(pregunta.getCategoria());
        dto.setCostoEnergia(pregunta.getCostoEnergia());
        dto.setEstado(pregunta.getEstado());
        return dto;
    }
}