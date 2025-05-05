package com.videojuego.web.service;

import com.videojuego.web.dto.ReporteCompletoDTO;
import com.videojuego.web.dto.RespuestaReporteDTO;
import com.videojuego.web.model.Jugador;
import com.videojuego.web.model.Partida;
import com.videojuego.web.model.RespuestaJugador;
import com.videojuego.web.repository.PartidaRepository;
import org.hibernate.Hibernate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
public class PartidaService {

    private static final Logger logger = LoggerFactory.getLogger(PartidaService.class);

    @Autowired
    private PartidaRepository partidaRepository;

    @Autowired
    private JugadorService jugadorService;

    @Transactional
    public Partida crearPartida(String nombrePerfil, String personaje) {
        logger.info("Creando partida para el jugador: {}, personaje: {}", nombrePerfil, personaje);

        // Verificar si el jugador existe
        Jugador jugador = jugadorService.findByNombrePerfil(nombrePerfil);
        if (jugador == null) {
            logger.error("El jugador con nombre {} no existe.", nombrePerfil);
            throw new RuntimeException("El jugador con nombre " + nombrePerfil + " no existe.");
        }

        // Crear una nueva partida
        Partida partida = new Partida();
        partida.setJugador(jugador);
        partida.setPersonaje(personaje);
        partida.setFechaInicio(LocalDateTime.now());
        Partida savedPartida = partidaRepository.save(partida);
        logger.info("Partida creada con id_partida: {}", savedPartida.getIdPartida());

        return savedPartida;
    }

    @Transactional(readOnly = true)
    public Partida findById(Integer id) {
        logger.debug("Buscando partida con id: {}", id);
        return partidaRepository.findById(id).orElse(null);
    }

    @Transactional
    public void actualizarPartida(Partida partida) {
        logger.debug("Actualizando partida con id: {}", partida.getIdPartida());
        partidaRepository.save(partida);
    }

    @Transactional(readOnly = true)
    public ReporteCompletoDTO obtenerReporteCompleto(Integer idPartida) {
        logger.info("Generando reporte completo para la partida con id: {}", idPartida);

        // Buscar la partida con sus relaciones cargadas (respuestas y preguntas)
        Partida partida = partidaRepository.findById(idPartida)
                .orElseThrow(() -> new RuntimeException("La partida con id " + idPartida + " no existe."));

        // Forzar la carga de las relaciones (si es necesario)
        Hibernate.initialize(partida.getJugador());
        List<RespuestaJugador> respuestas = partida.getRespuestas();
        if (respuestas != null) {
            respuestas.forEach(respuesta -> Hibernate.initialize(respuesta.getPregunta()));
        }

        // Construir el DTO del reporte
        ReporteCompletoDTO reporte = new ReporteCompletoDTO();
        reporte.setIdPartida(partida.getIdPartida());
        reporte.setNombrePerfil(partida.getJugador().getNombrePerfil());
        reporte.setPersonaje(partida.getPersonaje());
        reporte.setTiempoTotalPartida(partida.getTiempoTotalPartida());
        reporte.setAciertosPartida(partida.getAciertosPartida());
        reporte.setErroresPartida(partida.getErroresPartida());
        reporte.setFechaInicio(partida.getFechaInicio());

        // Construir la lista de respuestas
        List<RespuestaReporteDTO> respuestasDTO = new ArrayList<>();
        if (respuestas != null) {
            for (RespuestaJugador respuesta : respuestas) {
                RespuestaReporteDTO respuestaDTO = new RespuestaReporteDTO();
                respuestaDTO.setIdRespuesta(respuesta.getIdRespuesta());
                respuestaDTO.setTextoPregunta(respuesta.getPregunta().getTextoPregunta());
                respuestaDTO.setOpciones(respuesta.getPregunta().getOpciones());
                respuestaDTO.setRespuestaCorrecta(respuesta.getPregunta().getRespuestaCorrecta());
                respuestaDTO.setDificultad(respuesta.getPregunta().getDificultad());
                respuestaDTO.setCategoria(respuesta.getPregunta().getCategoria());
                respuestaDTO.setRespuestaDada(respuesta.getRespuestaDada());
                respuestaDTO.setEsCorrecta(respuesta.getEsCorrecta());
                respuestaDTO.setTiempoRespuesta(respuesta.getTiempoRespuesta());
                respuestasDTO.add(respuestaDTO);
            }
        }
        reporte.setRespuestas(respuestasDTO);

        logger.info("Reporte generado para la partida con id: {}", idPartida);
        return reporte;
    }
}