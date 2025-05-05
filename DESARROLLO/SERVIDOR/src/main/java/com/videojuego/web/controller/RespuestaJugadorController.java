package com.videojuego.web.controller;

import com.videojuego.web.dto.CreateRespuestaRequestDTO;
import com.videojuego.web.model.RespuestaJugador;
import com.videojuego.web.service.RespuestaJugadorService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/respuestas")
public class RespuestaJugadorController {

    @Autowired
    private RespuestaJugadorService respuestaJugadorService;

    @PostMapping
    public ResponseEntity<RespuestaJugador> registrarRespuesta(@RequestBody CreateRespuestaRequestDTO request) {
        RespuestaJugador respuesta = respuestaJugadorService.registrarRespuesta(request);
        return ResponseEntity.ok(respuesta);
    }
}