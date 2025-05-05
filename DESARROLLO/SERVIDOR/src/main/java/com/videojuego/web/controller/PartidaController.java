package com.videojuego.web.controller;

import com.videojuego.web.dto.CrearPartidaRequestDTO;
import com.videojuego.web.dto.PartidaDTO;
import com.videojuego.web.model.Partida;
import com.videojuego.web.service.PartidaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/partidas")
public class PartidaController {

    @Autowired
    private PartidaService partidaService;

    @PostMapping
    public ResponseEntity<PartidaDTO> crearPartida(@RequestBody CrearPartidaRequestDTO request) {
        Partida partida = partidaService.crearPartida(request.getNombrePerfil(), request.getPersonaje());
        PartidaDTO partidaDTO = new PartidaDTO();
        partidaDTO.setIdPartida(partida.getIdPartida().longValue());
        partidaDTO.setNombrePerfil(partida.getJugador().getNombrePerfil());
        partidaDTO.setPersonaje(partida.getPersonaje());
        partidaDTO.setTiempoTotalPartida(partida.getTiempoTotalPartida());
        partidaDTO.setAciertosPartida(partida.getAciertosPartida());
        partidaDTO.setErroresPartida(partida.getErroresPartida());
        partidaDTO.setFechaInicio(partida.getFechaInicio());
        return ResponseEntity.ok(partidaDTO);
    }
}