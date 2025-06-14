package com.videojuego.web.service;

import com.videojuego.web.dto.HistoricoPartidaDTO;
import com.videojuego.web.dto.ReporteCompletoDTO;
import com.videojuego.web.dto.RespuestaReporteDTO; // Importamos la clase independiente
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
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

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

        Jugador jugador = jugadorService.findByNombrePerfil(nombrePerfil);
        if (jugador == null) {
            logger.info("Jugador con nombre {} no existe, creando uno nuevo.", nombrePerfil);
            jugador = jugadorService.createJugador(nombrePerfil);
        }

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

        Partida partida = partidaRepository.findById(idPartida)
                .orElseThrow(() -> new RuntimeException("La partida con id " + idPartida + " no existe."));

        Hibernate.initialize(partida.getJugador());
        List<RespuestaJugador> respuestas = partida.getRespuestas();
        if (respuestas != null) {
            respuestas.forEach(respuesta -> Hibernate.initialize(respuesta.getPregunta()));
        }

        ReporteCompletoDTO reporte = new ReporteCompletoDTO();
        reporte.setIdPartida(partida.getIdPartida());
        reporte.setNombrePerfil(partida.getJugador().getNombrePerfil());
        reporte.setPersonaje(partida.getPersonaje());
        reporte.setTiempoTotalPartida(partida.getTiempoTotalPartida());
        reporte.setAciertosPartida(partida.getAciertosPartida());
        reporte.setErroresPartida(partida.getErroresPartida());
        reporte.setFechaInicio(partida.getFechaInicio());

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

    @Transactional(readOnly = true)
    public List<HistoricoPartidaDTO> obtenerHistoricoPartidas() {
        logger.info("Obteniendo histórico de partidas");

        List<Partida> partidas = partidaRepository.findAll();

        List<HistoricoPartidaDTO> historico = partidas.stream().map(partida -> {
                    HistoricoPartidaDTO dto = new HistoricoPartidaDTO();
                    dto.setIdPartida(partida.getIdPartida());
                    dto.setNombrePerfil(partida.getJugador().getNombrePerfil());
                    dto.setFechaInicio(partida.getFechaInicio());
                    dto.setAciertosPartida(partida.getAciertosPartida());
                    dto.setErroresPartida(partida.getErroresPartida());
                    dto.setTiempoTotalPartida(partida.getTiempoTotalPartida());
                    double puntuacion = (partida.getAciertosPartida() * 10) - (partida.getErroresPartida() * 5) - (partida.getTiempoTotalPartida() / 10.0);
                    dto.setPuntuacion(puntuacion);
                    return dto;
                })
                .sorted(Comparator.comparing(HistoricoPartidaDTO::getFechaInicio).reversed())
                .collect(Collectors.toList());

        logger.info("Se encontraron {} partidas en el histórico", historico.size());
        return historico;
    }
}