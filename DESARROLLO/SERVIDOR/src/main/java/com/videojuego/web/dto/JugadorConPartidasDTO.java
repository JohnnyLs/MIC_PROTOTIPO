package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class JugadorConPartidasDTO {
    private Integer idJugador;
    private String nombrePerfil;
    private Integer tiempoTotal;
    private Integer aciertosTotales;
    private Integer erroresTotales;
    private List<PartidaDTO> partidas;

    @Getter
    @Setter
    public static class PartidaDTO {
        private Integer idPartida;
        private String personaje;
        private LocalDateTime fechaInicio;
    }
}