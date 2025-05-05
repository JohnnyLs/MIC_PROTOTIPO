package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
public class PartidaDTO {
    private Long idPartida;
    private String nombrePerfil;
    private String personaje;
    private Integer tiempoTotalPartida;
    private Integer aciertosPartida;
    private Integer erroresPartida;
    private LocalDateTime fechaInicio;
}