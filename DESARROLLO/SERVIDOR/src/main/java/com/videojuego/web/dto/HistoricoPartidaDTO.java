package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class HistoricoPartidaDTO {
    private Integer idPartida;
    private String nombrePerfil;
    private LocalDateTime fechaInicio;
    private Integer aciertosPartida;
    private Integer erroresPartida;
    private Integer tiempoTotalPartida;
    private Double puntuacion;
}