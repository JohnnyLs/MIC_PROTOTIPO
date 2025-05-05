package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
public class ReporteCompletoDTO {
    private Integer idPartida;
    private String nombrePerfil;
    private String personaje;
    private Integer tiempoTotalPartida;
    private Integer aciertosPartida;
    private Integer erroresPartida;
    private LocalDateTime fechaInicio;
    private List<RespuestaReporteDTO> respuestas;
}