package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class TopJugadorDTO {
    private String nombrePerfil;
    private Integer aciertosTotales;
    private Integer erroresTotales;
    private Integer tiempoTotal;
    private Double puntuacion;
}