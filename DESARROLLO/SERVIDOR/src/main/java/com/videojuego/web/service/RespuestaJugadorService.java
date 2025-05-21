package com.videojuego.web.service;

import com.videojuego.web.dto.CreateRespuestaRequestDTO;
import com.videojuego.web.dto.RespuestaJugadorResponseDTO;
import com.videojuego.web.dto.TopJugadorPorCategoriaDTO;
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

import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

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

        Partida partida = partidaService.findById(request.getIdPartida());
        if (partida == null) {
            logger.error("La partida con id {} no existe.", request.getIdPartida());
            throw new RuntimeException("La partida con id " + request.getIdPartida() + " no existe.");
        }

        Pregunta pregunta = preguntaService.findById(request.getIdPregunta());
        if (pregunta == null) {
            logger.error("La pregunta con id {} no existe.", request.getIdPregunta());
            throw new RuntimeException("La pregunta con id " + request.getIdPregunta() + " no existe.");
        }

        if (!"activo".equals(pregunta.getEstado())) {
            logger.error("La pregunta con id {} está inactiva.", request.getIdPregunta());
            throw new RuntimeException("La pregunta con id " + request.getIdPregunta() + " está inactiva.");
        }

        RespuestaJugador respuesta = new RespuestaJugador();
        respuesta.setPartida(partida);
        respuesta.setPregunta(pregunta);
        respuesta.setRespuestaDada(request.getRespuestaDada());
        respuesta.setEsCorrecta(request.getEsCorrecta());
        respuesta.setTiempoRespuesta(request.getTiempoRespuesta());

        RespuestaJugador savedRespuesta = respuestaJugadorRepository.save(respuesta);
        logger.info("Respuesta registrada con id_respuesta: {}", savedRespuesta.getIdRespuesta());

        actualizarEstadisticas(partida, respuesta);

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
        if (respuesta.getEsCorrecta()) {
            partida.setAciertosPartida(partida.getAciertosPartida() + 1);
        } else {
            partida.setErroresPartida(partida.getErroresPartida() + 1);
        }
        partida.setTiempoTotalPartida(partida.getTiempoTotalPartida() + respuesta.getTiempoRespuesta());
        partidaService.actualizarPartida(partida);

        Jugador jugador = partida.getJugador();
        if (respuesta.getEsCorrecta()) {
            jugador.setAciertosTotales(jugador.getAciertosTotales() + 1);
        } else {
            jugador.setErroresTotales(jugador.getErroresTotales() + 1);
        }
        jugador.setTiempoTotal(jugador.getTiempoTotal() + respuesta.getTiempoRespuesta());
        jugadorService.actualizarJugador(jugador);
    }

    // Nuevo método para obtener los mejores jugadores por categoría
    @Transactional(readOnly = true)
    public List<TopJugadorPorCategoriaDTO> obtenerMejoresJugadoresPorCategoria(Integer limitePorCategoria) {
        logger.info("Obteniendo los mejores jugadores por categoría, límite: {}", limitePorCategoria);

        List<RespuestaJugador> respuestas = respuestaJugadorRepository.findAll();

        // Agrupar respuestas por categoría y jugador
        Map<String, Map<String, List<RespuestaJugador>>> respuestasPorCategoriaYJugador = respuestas.stream()
                .collect(Collectors.groupingBy(
                        respuesta -> respuesta.getPregunta().getCategoria(),
                        Collectors.groupingBy(
                                respuesta -> respuesta.getPartida().getJugador().getNombrePerfil()
                        )
                ));

        // Calcular estadísticas por categoría y jugador
        List<TopJugadorPorCategoriaDTO> resultado = respuestasPorCategoriaYJugador.entrySet().stream()
                .map(entry -> {
                    String categoria = entry.getKey();
                    Map<String, List<RespuestaJugador>> respuestasPorJugador = entry.getValue();

                    List<TopJugadorPorCategoriaDTO.JugadorCategoriaDTO> jugadoresDTO = respuestasPorJugador.entrySet().stream()
                            .map(jugadorEntry -> {
                                String nombrePerfil = jugadorEntry.getKey();
                                List<RespuestaJugador> respuestasJugador = jugadorEntry.getValue();

                                int aciertos = (int) respuestasJugador.stream().filter(RespuestaJugador::getEsCorrecta).count();
                                int errores = respuestasJugador.size() - aciertos;

                                TopJugadorPorCategoriaDTO.JugadorCategoriaDTO jugadorDTO = new TopJugadorPorCategoriaDTO.JugadorCategoriaDTO();
                                jugadorDTO.setNombrePerfil(nombrePerfil);
                                jugadorDTO.setAciertos(aciertos);
                                jugadorDTO.setErrores(errores);
                                // Puntuación por categoría: (Aciertos * 10) - (Errores * 5)
                                double puntuacion = (aciertos * 10) - (errores * 5);
                                jugadorDTO.setPuntuacion(puntuacion);
                                return jugadorDTO;
                            })
                            .sorted(Comparator.comparingDouble(TopJugadorPorCategoriaDTO.JugadorCategoriaDTO::getPuntuacion).reversed())
                            .limit(limitePorCategoria)
                            .collect(Collectors.toList());

                    TopJugadorPorCategoriaDTO categoriaDTO = new TopJugadorPorCategoriaDTO();
                    categoriaDTO.setCategoria(categoria);
                    categoriaDTO.setJugadores(jugadoresDTO);
                    return categoriaDTO;
                })
                .sorted(Comparator.comparing(TopJugadorPorCategoriaDTO::getCategoria))
                .collect(Collectors.toList());

        logger.info("Se encontraron estadísticas para {} categorías", resultado.size());
        return resultado;
    }
}