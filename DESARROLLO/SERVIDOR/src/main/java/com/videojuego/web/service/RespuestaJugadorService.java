package com.videojuego.web.service;

import com.videojuego.web.dto.CreateRespuestaRequestDTO;
import com.videojuego.web.dto.RespuestaJugadorResponseDTO;
import com.videojuego.web.model.Jugador;
import com.videojuego.web.model.Partida;
import com.videojuego.web.model.Pregunta;
import com.videojuego.web.model.RespuestaJugador;
import com.videojuego.web.repository.RespuestaJugadorRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RespuestaJugadorService {

    private static final Logger logger = LoggerFactory.getLogger(RespuestaJugadorService.class);

    @Autowired
    private RespuestaJugadorRepository respuestaJugadorRepository;

    @Autowired
    private PartidaService partidaService;

    @Autowired
    private PreguntaService preguntaService;

    @Autowired
    private JugadorService jugadorService;

    @Transactional
    public RespuestaJugadorResponseDTO registrarRespuesta(CreateRespuestaRequestDTO request) {
        logger.info("Registrando respuesta para idPartida: {}, idPregunta: {}", request.getIdPartida(), request.getIdPregunta());

        // Verificar que la partida exista
        Partida partida = partidaService.findById(request.getIdPartida());
        if (partida == null) {
            logger.error("La partida con id {} no existe.", request.getIdPartida());
            throw new RuntimeException("La partida con id " + request.getIdPartida() + " no existe.");
        }

        // Verificar que la pregunta exista
        Pregunta pregunta = preguntaService.findById(request.getIdPregunta());
        if (pregunta == null) {
            logger.error("La pregunta con id {} no existe.", request.getIdPregunta());
            throw new RuntimeException("La pregunta con id " + request.getIdPregunta() + " no existe.");
        }

        // Verificar que la pregunta esté activa
        if (!"activo".equals(pregunta.getEstado())) {
            logger.error("La pregunta con id {} está inactiva.", request.getIdPregunta());
            throw new RuntimeException("La pregunta con id " + request.getIdPregunta() + " está inactiva.");
        }

        // Crear la respuesta
        RespuestaJugador respuesta = new RespuestaJugador();
        respuesta.setPartida(partida);
        respuesta.setPregunta(pregunta);
        respuesta.setRespuestaDada(request.getRespuestaDada());
        respuesta.setEsCorrecta(request.getEsCorrecta());
        respuesta.setTiempoRespuesta(request.getTiempoRespuesta());

        // Guardar la respuesta
        RespuestaJugador savedRespuesta = respuestaJugadorRepository.save(respuesta);
        logger.info("Respuesta registrada con id_respuesta: {}", savedRespuesta.getIdRespuesta());

        // Actualizar estadísticas de la partida y el jugador
        actualizarEstadisticas(partida, respuesta);

        // Mapear la respuesta a un DTO para evitar problemas de serialización cíclica
        RespuestaJugadorResponseDTO responseDTO = new RespuestaJugadorResponseDTO();
        responseDTO.setIdRespuesta(savedRespuesta.getIdRespuesta());
        responseDTO.setIdPartida(partida.getIdPartida());
        responseDTO.setNombrePerfil(partida.getJugador().getNombrePerfil());
        responseDTO.setPersonaje(partida.getPersonaje());
        responseDTO.setIdPregunta(pregunta.getIdPregunta());
        responseDTO.setTextoPregunta(pregunta.getTextoPregunta());
        responseDTO.setOpciones(pregunta.getOpciones());
        responseDTO.setRespuestaCorrecta(pregunta.getRespuestaCorrecta());
        responseDTO.setRespuestaDada(savedRespuesta.getRespuestaDada());
        responseDTO.setEsCorrecta(savedRespuesta.getEsCorrecta());
        responseDTO.setTiempoRespuesta(savedRespuesta.getTiempoRespuesta());
        responseDTO.setFechaInicio(partida.getFechaInicio());

        return responseDTO;
    }

    private void actualizarEstadisticas(Partida partida, RespuestaJugador respuesta) {
        // Actualizar estadísticas de la partida
        if (respuesta.getEsCorrecta()) {
            partida.setAciertosPartida(partida.getAciertosPartida() + 1);
        } else {
            partida.setErroresPartida(partida.getErroresPartida() + 1);
        }
        partida.setTiempoTotalPartida(partida.getTiempoTotalPartida() + respuesta.getTiempoRespuesta());
        partidaService.actualizarPartida(partida);

        // Actualizar estadísticas del jugador
        Jugador jugador = partida.getJugador();
        if (respuesta.getEsCorrecta()) {
            jugador.setAciertosTotales(jugador.getAciertosTotales() + 1);
        } else {
            jugador.setErroresTotales(jugador.getErroresTotales() + 1);
        }
        jugador.setTiempoTotal(jugador.getTiempoTotal() + respuesta.getTiempoRespuesta());
        jugadorService.actualizarJugador(jugador);
    }
}