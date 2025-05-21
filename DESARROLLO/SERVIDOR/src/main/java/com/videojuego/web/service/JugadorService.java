package com.videojuego.web.service;

import com.videojuego.web.dto.JugadorConPartidasDTO;
import com.videojuego.web.dto.TopJugadorDTO;
import com.videojuego.web.model.Jugador;
import com.videojuego.web.model.Partida;
import com.videojuego.web.repository.JugadorRepository;
import org.hibernate.Hibernate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class JugadorService {

    private static final Logger logger = LoggerFactory.getLogger(JugadorService.class);

    @Autowired
    private JugadorRepository jugadorRepository;

    public Jugador findByNombrePerfil(String nombrePerfil) {
        logger.debug("Buscando jugador con nombrePerfil: {}", nombrePerfil);
        Jugador jugador = jugadorRepository.findByNombrePerfil(nombrePerfil).orElse(null);
        logger.debug("Resultado de la búsqueda: {}", jugador);
        return jugador;
    }

    @Transactional
    public Jugador createJugador(String nombrePerfil) {
        logger.info("Iniciando creación de jugador con nombrePerfil: {}", nombrePerfil);

        Jugador existingJugador = findByNombrePerfil(nombrePerfil);
        if (existingJugador != null) {
            logger.warn("El nombre de perfil {} ya está en uso.", nombrePerfil);
            throw new RuntimeException("El nombre de perfil " + nombrePerfil + " ya está en uso.");
        }

        logger.debug("Creando nuevo jugador...");
        Jugador jugador = new Jugador();
        jugador.setNombrePerfil(nombrePerfil);
        Jugador savedJugador = jugadorRepository.save(jugador);
        logger.info("Jugador creado con id_jugador: {}", savedJugador.getIdJugador());

        return savedJugador;
    }

    public Jugador findById(Integer id) {
        logger.debug("Buscando jugador con id: {}", id);
        return jugadorRepository.findById(id).orElse(null);
    }

    @Transactional
    public void actualizarJugador(Jugador jugador) {
        logger.debug("Actualizando jugador con id: {}", jugador.getIdJugador());
        jugadorRepository.save(jugador);
    }

    @Transactional(readOnly = true)
    public List<JugadorConPartidasDTO> obtenerTodosLosJugadoresConPartidas() {
        logger.info("Buscando todos los jugadores con sus partidas");

        List<Jugador> jugadores = jugadorRepository.findAll();

        List<JugadorConPartidasDTO> jugadoresDTO = jugadores.stream().map(jugador -> {
            Hibernate.initialize(jugador.getPartidas());

            JugadorConPartidasDTO jugadorDTO = new JugadorConPartidasDTO();
            jugadorDTO.setIdJugador(jugador.getIdJugador());
            jugadorDTO.setNombrePerfil(jugador.getNombrePerfil());
            jugadorDTO.setTiempoTotal(jugador.getTiempoTotal());
            jugadorDTO.setAciertosTotales(jugador.getAciertosTotales());
            jugadorDTO.setErroresTotales(jugador.getErroresTotales());

            List<JugadorConPartidasDTO.PartidaDTO> partidasDTO = jugador.getPartidas().stream().map(partida -> {
                JugadorConPartidasDTO.PartidaDTO partidaDTO = new JugadorConPartidasDTO.PartidaDTO();
                partidaDTO.setIdPartida(partida.getIdPartida());
                partidaDTO.setPersonaje(partida.getPersonaje());
                partidaDTO.setFechaInicio(partida.getFechaInicio());
                return partidaDTO;
            }).collect(Collectors.toList());

            jugadorDTO.setPartidas(partidasDTO);
            return jugadorDTO;
        }).collect(Collectors.toList());

        logger.info("Se encontraron {} jugadores con sus partidas", jugadoresDTO.size());
        return jugadoresDTO;
    }

    // Nuevo método para obtener los mejores jugadores en general
    @Transactional(readOnly = true)
    public List<TopJugadorDTO> obtenerMejoresJugadores(Integer limite) {
        logger.info("Obteniendo los {} mejores jugadores en general", limite);

        List<Jugador> jugadores = jugadorRepository.findAll();

        List<TopJugadorDTO> topJugadores = jugadores.stream().map(jugador -> {
                    TopJugadorDTO dto = new TopJugadorDTO();
                    dto.setNombrePerfil(jugador.getNombrePerfil());
                    dto.setAciertosTotales(jugador.getAciertosTotales());
                    dto.setErroresTotales(jugador.getErroresTotales());
                    dto.setTiempoTotal(jugador.getTiempoTotal());
                    // Calcular puntuación: (Aciertos * 10) - (Errores * 5) - (Tiempo / 10)
                    double puntuacion = (jugador.getAciertosTotales() * 10) - (jugador.getErroresTotales() * 5) - (jugador.getTiempoTotal() / 10.0);
                    dto.setPuntuacion(puntuacion);
                    return dto;
                })
                .sorted(Comparator.comparingDouble(TopJugadorDTO::getPuntuacion).reversed())
                .limit(limite)
                .collect(Collectors.toList());

        logger.info("Se encontraron {} jugadores, devolviendo los {} mejores", jugadores.size(), topJugadores.size());
        return topJugadores;
    }
}