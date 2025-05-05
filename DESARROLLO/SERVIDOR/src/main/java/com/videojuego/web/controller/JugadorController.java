package com.videojuego.web.controller;

import com.videojuego.web.dto.JugadorConPartidasDTO;
import com.videojuego.web.model.Jugador;
import com.videojuego.web.service.JugadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/con_jugadores")
public class JugadorController {

    @Autowired
    private JugadorService jugadorService;

    @GetMapping("/exists/{nombrePerfil}")
    public ResponseEntity<Boolean> existsByNombrePerfil(@PathVariable String nombrePerfil) {
        Jugador jugador = jugadorService.findByNombrePerfil(nombrePerfil);
        return ResponseEntity.ok(jugador != null);
    }

    @PostMapping
    public ResponseEntity<Jugador> createJugador(@RequestBody String nombrePerfil) {
        Jugador jugador = jugadorService.createJugador(nombrePerfil);
        return ResponseEntity.ok(jugador);
    }

    @GetMapping
    public ResponseEntity<List<JugadorConPartidasDTO>> obtenerTodosLosJugadoresConPartidas() {
        List<JugadorConPartidasDTO> jugadores = jugadorService.obtenerTodosLosJugadoresConPartidas();
        return ResponseEntity.ok(jugadores);
    }
}