package com.videojuego.web.controller;

import com.videojuego.web.model.Jugador;
import com.videojuego.web.service.JugadorService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/admin/jugadores")
public class AdminJugadorController {

    private static final Logger logger = LoggerFactory.getLogger(AdminJugadorController.class);

    @Autowired
    private JugadorService jugadorService;

    // Editar un jugador existente
    @PutMapping("/{id}")
    public ResponseEntity<Jugador> editarJugador(
            @PathVariable Integer id,
            @RequestBody JugadorDTO jugadorDTO) {
        logger.info("Solicitud PUT para editar jugador con id: {}", id);
        Jugador jugadorActualizado = jugadorService.editarJugador(
                id,
                jugadorDTO.getNombrePerfil(),
                jugadorDTO.getTiempoTotal(),
                jugadorDTO.getAciertosTotales(),
                jugadorDTO.getErroresTotales()
        );
        return ResponseEntity.ok(jugadorActualizado);
    }

    // Eliminar un jugador
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarJugador(@PathVariable Integer id) {
        logger.info("Solicitud DELETE para eliminar jugador con id: {}", id);
        jugadorService.eliminarJugador(id);
        return ResponseEntity.noContent().build();
    }
}

// DTO para manejar las solicitudes de edición
class JugadorDTO {
    private String nombrePerfil;
    private Integer tiempoTotal;
    private Integer aciertosTotales;
    private Integer erroresTotales;

    // Getters y setters
    public String getNombrePerfil() {
        return nombrePerfil;
    }

    public void setNombrePerfil(String nombrePerfil) {
        this.nombrePerfil = nombrePerfil;
    }

    public Integer getTiempoTotal() {
        return tiempoTotal;
    }

    public void setTiempoTotal(Integer tiempoTotal) {
        this.tiempoTotal = tiempoTotal;
    }

    public Integer getAciertosTotales() {
        return aciertosTotales;
    }

    public void setAciertosTotales(Integer aciertosTotales) {
        this.aciertosTotales = aciertosTotales;
    }

    public Integer getErroresTotales() {
        return erroresTotales;
    }

    public void setErroresTotales(Integer erroresTotales) {
        this.erroresTotales = erroresTotales;
    }
}