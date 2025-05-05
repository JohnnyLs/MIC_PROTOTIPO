package com.videojuego.web.controller;

import com.videojuego.web.dto.ReporteCompletoDTO;
import com.videojuego.web.service.PartidaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reportes")
public class ReporteController {

    @Autowired
    private PartidaService partidaService;

    @GetMapping("/{idPartida}")
    public ResponseEntity<ReporteCompletoDTO> obtenerReporteCompleto(@PathVariable Integer idPartida) {
        ReporteCompletoDTO reporte = partidaService.obtenerReporteCompleto(idPartida);
        return ResponseEntity.ok(reporte);
    }
}