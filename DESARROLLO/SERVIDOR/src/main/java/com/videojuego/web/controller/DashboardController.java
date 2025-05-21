package com.videojuego.web.controller;

import com.videojuego.web.dto.HistoricoPartidaDTO;
import com.videojuego.web.dto.TopJugadorDTO;
import com.videojuego.web.dto.TopJugadorPorCategoriaDTO;
import com.videojuego.web.service.JugadorService;
import com.videojuego.web.service.PartidaService;
import com.videojuego.web.service.RespuestaJugadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/dashboard")
public class DashboardController {

    @Autowired
    private JugadorService jugadorService;

    @Autowired
    private RespuestaJugadorService respuestaJugadorService;

    @Autowired
    private PartidaService partidaService;

    // Endpoint para los mejores jugadores en general
    @GetMapping("/top-jugadores/{limite}")
    public ResponseEntity<List<TopJugadorDTO>> obtenerMejoresJugadores(@PathVariable Integer limite) {
        List<TopJugadorDTO> topJugadores = jugadorService.obtenerMejoresJugadores(limite);
        return ResponseEntity.ok(topJugadores);
    }

    // Endpoint para los mejores jugadores por categoría
    @GetMapping("/top-jugadores-categoria/{limite}")
    public ResponseEntity<List<TopJugadorPorCategoriaDTO>> obtenerMejoresJugadoresPorCategoria(@PathVariable Integer limite) {
        List<TopJugadorPorCategoriaDTO> topPorCategoria = respuestaJugadorService.obtenerMejoresJugadoresPorCategoria(limite);
        return ResponseEntity.ok(topPorCategoria);
    }

    // Endpoint para el histórico de partidas
    @GetMapping("/historico-partidas")
    public ResponseEntity<List<HistoricoPartidaDTO>> obtenerHistoricoPartidas() {
        List<HistoricoPartidaDTO> historico = partidaService.obtenerHistoricoPartidas();
        return ResponseEntity.ok(historico);
    }
}