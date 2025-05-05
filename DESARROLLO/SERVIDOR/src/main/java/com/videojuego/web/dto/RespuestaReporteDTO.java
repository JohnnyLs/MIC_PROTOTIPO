package com.videojuego.web.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RespuestaReporteDTO {
    private Integer idRespuesta;
    private String textoPregunta;
    private String opciones;
    private String respuestaCorrecta;
    private String dificultad;
    private String categoria;
    private String respuestaDada;
    private Boolean esCorrecta;
    private Integer tiempoRespuesta;
}